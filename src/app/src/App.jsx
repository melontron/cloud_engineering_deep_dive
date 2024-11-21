import { useState, useRef } from 'react'
import axios from 'axios'
import './App.css'

function App() {
  const [baseUrl, setBaseUrl] = useState('http://localhost:4444')
  const [concurrentRequests, setConcurrentRequests] = useState(10)
  const [requestInterval, setRequestInterval] = useState(10000)
  const [responses, setResponses] = useState([])
  const [isLoading, setIsLoading] = useState(false)
  const intervalRef = useRef(null)

  const makeRequest = async (requestId) => {
    try {
      const response = await axios.get(`${baseUrl}/run`)
      setResponses((prevResponses) => {
        const updatedResponses = prevResponses.map((resp) => {
          if (resp.requestId === requestId) {
            return { ...resp, status: response.data.message }
          }
          return resp
        })
        return updatedResponses
      })

      setTimeout(() => {
        setResponses((prevResponses) =>
          prevResponses.filter((resp) => resp.requestId !== requestId)
        )
      }, 1000)
    } catch (error) {
      console.error('Request failed:', error.message)
    }
  }

  const makeConcurrentRequests = async () => {
    const requests = []

    for (let i = 0; i < concurrentRequests; i++) {
      const requestId = Date.now() + i
      requests.push({ requestId, status: 'Pending' })
      makeRequest(requestId)
    }

    setResponses((prevResponses) => [...prevResponses, ...requests])
  }

  const startLoadTest = () => {
    console.log('Starting load test...')
    setIsLoading(true)
    intervalRef.current = setInterval(makeConcurrentRequests, requestInterval)
  }

  const stopLoadTest = () => {
    console.log('Stopping load test...')
    setIsLoading(false)
    clearInterval(intervalRef.current)
  }

  return (
    <div className="app">
      <h1>Load Test</h1>
      <div className="input-container">
        <div className="input-group">
          <label>Base URL:</label>
          <input
            type="text"
            value={baseUrl}
            onChange={(e) => setBaseUrl(e.target.value)}
          />
        </div>
        <div className="input-group">
          <label>Concurrent Requests:</label>
          <input
            type="number"
            value={concurrentRequests}
            onChange={(e) => setConcurrentRequests(Number(e.target.value))}
          />
        </div>
        <div className="input-group">
          <label>Request Interval (ms):</label>
          <input
            type="number"
            value={requestInterval}
            onChange={(e) => setRequestInterval(Number(e.target.value))}
          />
        </div>
      </div>
      <button className="load-test-button" onClick={isLoading ? stopLoadTest : startLoadTest}>
        {isLoading ? 'Stop Load Test' : 'Start Load Test'}
      </button>
      <h2>Requests:</h2>
      <table className="requests-table">
        <thead>
          <tr>
            <th>Request ID</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {responses.map((response) => (
            <tr key={response.requestId}>
              <td>{response.requestId}</td>
              <td>{response.status}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

export default App
