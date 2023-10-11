import React from 'react';

function ResourceList({ resources, onDelete }) {
    return (
        <div>
            <h2 className='text-center pt-3'>Resource List</h2>
            <ul>
                {resources.map((resource, index) => (
                    <li key={index}>
                        <strong>Name:</strong> {resource.name}, <strong>Disk Size:</strong> {resource.size},{' '}
                        <strong>Size:</strong> {resource.disk_size}, <strong>Image:</strong> {resource.image},{' '}
                        <strong>Count:</strong> {resource.count}, <strong>Service:</strong> {resource.service}
                        <button className='btn btn-danger' onClick={() => onDelete(index)}>Delete</button>
                    </li>
                ))}
            </ul>
        </div>
    );
}

export default ResourceList;