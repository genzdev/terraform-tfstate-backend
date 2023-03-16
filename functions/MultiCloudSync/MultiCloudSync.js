'use strict';

const { S3 } = require('@aws-sdk/client-s3');
const { Storage } = require('@google-cloud/storage');
const {
  BlobServiceClient,
  StorageSharedKeyCredential,
} = require('@azure/storage-blob');

const S3Client = new S3({
  region: process.env.REGION,
});

const ACCESS_KEY = process.env.AZURE_STORAGE_ACCOUNT_ACCESS_KEY;

const STATE_BUCKET = process.env.STATE_BUCKET;

const STATE_OBJ_KEY = `env:/${process.env.ENV_STAGE}/${process.env.ENV_STAGE}.tfstate`;

const sharedKeyCredential = new StorageSharedKeyCredential(
  'axerstandard',
  ACCESS_KEY
);

const blobServiceClient = new BlobServiceClient(
  'https://axerstandard.blob.core.windows.net',
  sharedKeyCredential
);

const containerClient = blobServiceClient.getContainerClient(STATE_BUCKET);

const blockBlobClient = containerClient.getBlockBlobClient(STATE_OBJ_KEY);

const storage = new Storage();

const myBucket = storage.bucket(STATE_BUCKET);

const tfstatefile = myBucket.file(STATE_OBJ_KEY);

/**
 * Handler for MultiCloudSync lambda
 * @param {Object} event
 * @returns
 */

exports.handler = async (event) => {
  console.log('handler started -->', event);
  await uploadToGCS(STATE_BUCKET);
  await uploadToAzure(STATE_BUCKET);
  return {
    statusCode: 200,
    body: JSON.stringify('Hello from MultiCloudSync Lambda!!'),
  };
};

/**
 * Function to upload State file to GCS.
 * @param {String} bucket
 */

const uploadToGCS = async (bucket) => {
  try {
    const data = await S3Client.getObject({
      Bucket: bucket,
      Key: STATE_OBJ_KEY,
    });
    console.log(data);
    const inputStream = data.Body;
    const BodyContents = await streamToString(inputStream);
    console.log(BodyContents);
    console.log(typeof BodyContents);
    const saveResponse = await tfstatefile.save(BodyContents, {
      contentType: 'application/json',
    });
    console.log(saveResponse);
  } catch (err) {
    console.error(err);
  }
};

/**
 * Function to upload State file to Azure Storage Container
 * @param {String} bucket
 */

const uploadToAzure = async (bucket) => {
  try {
    const data = await S3Client.getObject({
      Bucket: bucket,
      Key: STATE_OBJ_KEY,
    });
    console.log(data);
    const inputStream = data.Body;
    const BodyContents = await streamToString(inputStream);
    console.log(BodyContents);
    const saveResponse = await blockBlobClient.upload(
      BodyContents,
      BodyContents.length
    );
    console.log(saveResponse);
  } catch (err) {
    console.error(err);
  }
};

/**
 * Utility to convert Stream to String
 * @param {ReadableStream} stream
 * @returns
 */

const streamToString = (stream) =>
  new Promise((resolve, reject) => {
    const chunks = [];
    stream.on('data', (chunk) => chunks.push(chunk));
    stream.on('error', reject);
    stream.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
  });
