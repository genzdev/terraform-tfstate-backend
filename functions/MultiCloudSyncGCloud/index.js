'use strict';

const functions = require('@google-cloud/functions-framework');
const { S3 } = require('@aws-sdk/client-s3');
const { Storage } = require('@google-cloud/storage');
const {
  BlobServiceClient,
  StorageSharedKeyCredential,
} = require('@azure/storage-blob');

const STATE_BUCKET = process.env.STATE_BUCKET;
const STATE_OBJ_KEY = `env:/${process.env.ENV}/${process.env.ENV}.tfstate`;

const storage = new Storage();
const bucket = storage.bucket(STATE_BUCKET);
const tfstateFile = bucket.file(STATE_OBJ_KEY);

const S3Client = new S3({
  region: 'ca-central-1',
});

const ACCESS_KEY = process.env.AZURE_ACCESS_KEY;

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

functions.cloudEvent('MultiCloudSync', async (cloudEvent) => {
  console.log(cloudEvent);
  if (cloudEvent.data.name != STATE_OBJ_KEY) return;
  await uploadToAWS(STATE_BUCKET, STATE_OBJ_KEY);
  await uploadToAzure();
  // Your code here
  // Access the CloudEvent data payload via cloudEvent.data
});

/**
 * Function to upload data from GCS to AWS S3
 * @param {String} Bucket S3 bucket name
 * @param {String} Key S3 key name
 */

const uploadToAWS = async (Bucket, Key) => {
  try {
    const downloadedData = await tfstateFile.download();
    console.log(downloadedData);
    const Body = downloadedData[0];
    const data = await S3Client.putObject({
      Bucket,
      Key,
      Body,
    });
    console.log('S3 upload: ', data);
  } catch (e) {
    console.error(e);
  }
};

/**
 * Function to upload data from GCS to Azure Blob Container.
 */

const uploadToAzure = async () => {
  try {
    const downloadedData = await tfstateFile.download();
    console.log(downloadedData);
    const Body = downloadedData[0];
    const res = await blockBlobClient.uploadData(Body);
    console.log('Azure upload: ', res);
  } catch (e) {
    console.error(e);
  }
};
