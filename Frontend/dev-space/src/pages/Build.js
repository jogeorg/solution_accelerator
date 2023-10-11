import '../App.css';
import AddVM from '../components/addVM';
import React, { useState } from 'react';
import ResourceList from '../components/resourceList';

function Build() {
  // Initialize the resources state with an empty array
  const [resources, setResources] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const payload = JSON.stringify(resources);
  const addResource = (newResource) => {
    // Use the setResources function to add a new resource to the array
    setResources((prevResources) => [...prevResources, newResource]);
  };

  const handleDelete = (index) => {
    // Use the setResources function to remove a resource from the array by filtering
    setResources((prevResources) => prevResources.filter((_, i) => i !== index));
  };

  const handleSubmit = () => {
    // Send the payload JSON to a URL using fetch
    setIsLoading(true); // Set loading state to true while fetching

    fetch('http://localhost:8080/receive-json', {
      method: 'POST',
      body: payload,
      headers: {
        'Content-Type': 'application/json',
      },
    })
      .then((response) => {
        setIsLoading(false); // Set loading state back to false
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then((data) => {
        console.log('Data sent successfully:', data);
      })
      .catch((error) => {
        console.error('There was a problem with the fetch operation:', error);
        return
      });
  };

  const toggleDarkMode = () => {
    setIsDarkMode((prevMode) => !prevMode);
    isDarkMode ? document.documentElement.setAttribute('data-bs-theme', 'light') : document.documentElement.setAttribute('data-bs-theme', 'dark');
  };

  return (
    <div className='container '>
      <div className="row align-items-start">
        <div className="row text-center">
          <h1>Welcome to Azure Dev Space</h1>
          <button
            id='btnSwitch'
            className='btn btn-secondary col-1'
            onClick={toggleDarkMode}
          >
            {isDarkMode ? 'Light Mode' : 'Dark Mode'}
          </button>
        </div>

        <div className="">
          <div className="row">
            <h2>Resources</h2>
          </div>
          <div className="row pb-3">
            <AddVM Title="add Basic VM" Service="none" onAddResource={addResource} />
            <AddVM Title="add Domain Controller" Service="dc" onAddResource={addResource} />
            <AddVM Title="add ADFS" Service="adfs" onAddResource={addResource} />
            <AddVM Title="add AAD Connect" Service="aadc" onAddResource={addResource} />
            <AddVM Title="add SQL server" Service="sql" onAddResource={addResource} />
            <AddVM Title="add Certificate Authority" Service="ca" onAddResource={addResource} />
          </div>
        </div>
      </div>
      {/* <div className="col-4 border border-success vh-100">
          <h3>This is where I will put chatGPT</h3>
        </div> */}
      <div className="row">
        <div>
          <ResourceList resources={resources} onDelete={handleDelete} />
          <p>{payload}</p>
        </div>
      </div>
      <div className='row'>
        <button
          id="SubmitBtn"
          className='btn btn-primary btn-lg col-1'
          onClick={handleSubmit} // Attach the submit function to the button click event
          disabled={isLoading} // Disable the button when loading
        >
          {isLoading ? 'Loading...' : 'Submit'} {/* Show "Loading..." while loading */}
        </button>
      </div>
    </div>
  );
}

export default Build;
