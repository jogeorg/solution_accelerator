import React, { useState } from 'react';

function AddVM(props) {
    const [showForm, setShowForm] = useState(false);

    const toggleShow = () => {
        setShowForm(!showForm);
    }

    const addResource = (formData) => {
        // Create a new object with the form data
        const newResource = {
            name: formData.VMname.value,
            size: formData.size.value,
            disk_size: formData.disk_size.value,
            image: formData.image.value,
            count: formData.VMcount.value,
            service: formData.Service.value,
        };

        props.onAddResource(newResource);
        setShowForm(false);
    }

    const handleSubmit = (event) => {
        event.preventDefault(); // Prevent the default form submission behavior
        // Your form submission logic here, e.g., call a function like addResource
        const form = event.target;

        addResource(form)
    }

    return (
        <div className='col'>
            <div className='col'>
                <button className="btn btn-outline-primary btn-lg" onClick={toggleShow}>{props.Title}</button>

                {showForm && (
                    <div className="row">
                        <form onSubmit={handleSubmit}>
                            <div className="col">
                                <label htmlFor="VMname" className="form-label">VM Name</label>
                                <input type="text" className="form-control" id="VMname" aria-describedby="VMname"></input>
                            </div>
                            <div className="col">
                                <label htmlFor="disk_size" className="form-label">disk size</label>
                                <select className="form-select" id="disk_size" aria-label="Default select example">
                                    <option value="128">128</option>
                                    <option value="256">256</option>
                                    <option value="512">512</option>
                                </select>
                            </div>
                            <div className="col">
                                <label htmlFor="size" className="form-label">vm size</label>
                                <select className="form-select" id="size" aria-label="Default select example">
                                    <option value="Standard_D2s">Standard_D2s</option>
                                    <option value="Standard_D4s">Standard_D4s</option>
                                    <option value="Standard_D8s">Standard_D8s</option>
                                </select>
                            </div>
                            <div className="col">
                                <label htmlFor="image" className="form-label">image</label>
                                <select className="form-select" id="image" aria-label="Default select example">
                                    <option value="Windows">Windows</option>
                                    <option value="Ubuntu">Ubuntu</option>
                                    <option value="RHEL">RHEL</option>
                                </select>
                            </div>
                            <div className="col">
                                <label htmlFor="VMcount" className="form-label">Count</label>
                                <input type="number" className="form-control" id="VMcount"></input>
                            </div>
                            <div className="col">
                                <label htmlFor="Service" className="form-label">Service</label>
                                <input type="hidden" className="form-control" id="Service" value={props.Service}></input>
                            </div>
                            <div className="col d-flex align-items-end">
                                <input type="submit" className="btn btn-primary" value="Add"></input>
                            </div>
                        </form>
                    </div>
                )}
            </div>
        </div>
    );
}

export default AddVM;