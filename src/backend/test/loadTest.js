const axios = require('axios');

const BASE_URL = 'http://dev-backend-alb-1236518368.us-east-1.elb.amazonaws.com'; 
const CONCURRENT_REQUESTS = 6; 
const REQUEST_INTERVAL = 1000; 

const makeRequest = async () => {
  try {
    const response = await axios.get(`${BASE_URL}/run`);
    console.log('Request successful:', response.data);
  } catch (error) {
    console.error('Request failed:', error.message);
  }
};

const makeConcurrentRequests = async () => {
  const requests = [];

  for (let i = 0; i < CONCURRENT_REQUESTS; i++) {
    requests.push(makeRequest());
  }

  await Promise.all(requests);
};

// Function to start the load test
const startLoadTest = async () => {
  console.log('Starting load test...');

  // Make concurrent requests at regular intervals
  setInterval(makeConcurrentRequests, REQUEST_INTERVAL);
};

// Start the load test
startLoadTest();