'use strict';

const { S3 } = require('@aws-sdk/client-s3');
const { fromEnv } = require('@aws-sdk/credential-providers');
const { Storage } = require('@google-cloud/storage');

const STATE_BUCKET = process.env.STATE_BUCKET;
const STATE_OBJ_KEY = `env:/${process.env.ENV}/${process.env.ENV}.tfstate`;

const S3Client = new S3({
  region: 'ca-central-1',
  credentials: fromEnv(),
});

const storage = new Storage({
  projectId: 'ax-dev-0',
  credentials: require('./azureServiceAccount.json'),
});

const myBucket = storage.bucket(STATE_BUCKET);

const tfstatefile = myBucket.file(STATE_OBJ_KEY);

module.exports = async function (context, myBlob) {
  try {
    context.log(
      'JavaScript blob trigger function processed blob \n Blob:',
      context.bindingData.blobTrigger,
      '\n Blob Size:',
      myBlob.length,
      'Bytes'
    );
    context.log('input blob: ', context.bindings.inputBlob);
    context.log('input blob data type: ', typeof context.bindings.inputBlob);

    const s3Data = await S3Client.putObject({
      Bucket: STATE_BUCKET,
      Key: STATE_OBJ_KEY,
      Body: JSON.stringify(context.bindings.inputBlob),
    });

    context.log('S3 upload: ', s3Data);

    const gcsData = await tfstatefile.save(
      JSON.stringify(context.bindings.inputBlob),
      {
        contentType: 'application/json',
      }
    );
    context.log('GCS upload: ', gcsData);
  } catch (e) {
    context.log.error(e);
  }
};
