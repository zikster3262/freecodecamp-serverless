const fetch = require('node-fetch')

exports.handler = async (event, context) => {
  const url = 'https://api.magicthegathering.io/v1'
  console.log(event.path)

  try {
    let response, json

    if (event.path === '/cards' || event.path === '/cards/') {
      response = await fetchURL(url + event.path)
    } else if (event.path === '/sets' || event.path === '/sets/') {
      response = await fetchURL(url + event.path)
    } else if (event.path === '/types' || event.path === '/types/') {
      response = await fetchURL(url + event.path)
    } else if (event.path === '/subtypes' || event.path === '/subtypes/') {
      response = await fetchURL(url + event.path)
    } else if (event.path === '/supertypes' || event.path === '/supertypes/') {
      response = await fetchURL(url + event.path)
    } else if (event.path === '/formats' || event.path === '/formats/') {
      response = await fetchURL(url + event.path)
    } else if (/^\/cards\/\d+$/.test(event.path)) {
      response = await fetchURL(url + event.path)
    } else if (/^\/sets\/\w+$/.test(event.path)) {
      response = await fetchURL(url + event.path)
    } else {
      return {
        statusCode: 404,
        body: 'Not Found 404.'
      }
    }

    if (response) {
      json = await response.json()
      return {
        statusCode: 200,
        body: JSON.stringify(json)
      }
    }
  } catch (error) {
    return returnError(error)
  }
}

async function fetchURL (url, method = 'GET') {
  const response = await fetch(url, { method })
  return response
}

function returnError (error) {
  console.error('Error:', error)
  return {
    statusCode: 500,
    body: 'Internal error occurred'
  }
}
