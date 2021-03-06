const fs = require('fs-extra')
const path = require('path')
const R = require('ramda')
const { Future } = require('ramda-fantasy')

const AWS = require('aws-sdk')
AWS.config.loadFromPath(path.resolve(__dirname, './config.json'))

// create an elasticsearch client for your Amazon ES
const { USERS_ES_ENDPOINTS, USERS_INDEX, USERS_TYPE } = require('./def')
let es = require('elasticsearch')
  .Client({
    hosts: USERS_ES_ENDPOINTS,
    connectionClass: require('http-aws-es')
  })

const esSearchAsync = R.curry((index, type, body) =>
  Future((reject, resolve) => {
    es.search({
      index,
      type,
      body
    }, (err, data) => {
      if (err) { reject(err) } else { resolve(data) }
    })
  })
)

module.exports = esSearchAsync(USERS_INDEX, USERS_TYPE)
