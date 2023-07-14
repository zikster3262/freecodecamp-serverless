const fetch = require('node-fetch')
const AWS = require('aws-sdk')
const dynamodb = new AWS.DynamoDB()
const docClient = new AWS.DynamoDB.DocumentClient()

exports.handler = async event => {
  if (event.path === '/' && event.httpMethod === 'POST') {
    const body = JSON.parse(event.body)
    const apigw = process.env.API_GW
    const randomString = Math.random().toString(36).substring(2, 7)

    let shortURL = `${apigw}/${randomString}`

    // Check for URL in the body
    if (!body.url) {
      returnError(error, 400, 'Missing URL in the body')
    }

    try {
      // Construct params from the inputs
      const params = {
        TableName: process.env.DYNAMO_TABLE,
        Item: {
          UrlId: { S: body.url },
          ShortURL: { S: randomString }
        }
      }

      // Insert record into dynamo table
      await dynamodb.putItem(params).promise()

      return {
        statusCode: 200,
        body: JSON.stringify({
          message: 'URL has been created',
          shortURL: shortURL
        })
      }
    } catch (error) {
      returnError(error, 500, 'Internal error occurred')
    }
  } else if (event.httpMethod === 'GET' && /^\/\w+$/.test(event.path)) {
    const path = event.path
    const shortURL = path.replace('/', '')

    const params = {
      TableName: process.env.DYNAMO_TABLE,
      Key: {
        ShortURL: { S: shortURL }
      }
    }

    const data = await docClient.get(params).promise()
    console.log('Retrieved item:', data.Item)

    return {
      statusCode: 200,
      body: 'Found'
    }
  } else {
    return {
      statusCode: 404,
      body: 'Not Found 404.'
    }
  }
}

function returnError (error, code, message) {
  console.error('Error:', error)
  return {
    statusCode: code,
    body: JSON.stringify(message)
  }
}
