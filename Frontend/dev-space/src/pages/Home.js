import React, { useState, useEffect } from "react";
import { Outlet, Link, } from "react-router-dom";
import { getSelectedTeam, setSelectedTeam, selectedTeam } from "../components/resourceData";

export const teams = [];

const Home = () => {
    // Step 1: Initialize state for button labels and handlers
    const [buttons, setButtons] = useState([]);

    // Step 2: Create a state for the new button label
    const [newButtonLabel, setNewButtonLabel] = useState("");
    const [showInputField, setShowInputField] = useState(false);

    // Step 3: Function to add a new button
    const addNewButton = () => {
        if (newButtonLabel.trim() !== "") {
            const labelName = newButtonLabel.trim();
            teams.push(labelName);
            console.log(teams)
            setButtons([
                ...buttons,
                { label: labelName, },
            ]);

            setNewButtonLabel(""); // Clear the input field
        }
    };

    const fetchFolderNames = async () => {
        try {
            const url = 'https://dev.azure.com/ArmyEnterpriseServices/Army%20Enterprise%20Services/_apis/git/repositories/Azure_IaaS/items?scopePath=/Azure/variables&recursionLevel=OneLevel&api-version=7.0';
            const authHeaderValue = 'Basic ' + btoa(':' + '<INSERT YOUR PAT FOR DEV>');
            var folderNames = [];
            fetch(url, {
                method: 'GET',
                headers: {
                    'Authorization': authHeaderValue,
                },
            })
                .then((response) => response.json())
                .then((data) => {
                    console.log('Response data:', data);
                    folderNames = parseFolderNamesFromResponse(data);
                    // Update the buttons state with the folder names
                    setButtons(
                        folderNames.map((name) => ({ label: name }))
                    );
                })
                .catch((error) => {
                    console.error('Error:', error);
                });

            // Update the buttons state with the folder names
            setButtons(
                folderNames.map((name) => ({ label: name, }))
            );
        } catch (error) {
            console.error("Error fetching folder names:", error);
        }
    };

    const parseFolderNamesFromResponse = (response) => {
        if (!response || !response.value || !Array.isArray(response.value)) {
            return [];
        }

        // Extract "path" values from the "value" array
        var paths = response.value.map((item) => item.path.replace('/Azure/variables/', ''));
        paths.shift()

        return paths;
    }

    const TeamSelect = (team) => {
        setSelectedTeam(team);
    };

    // Use the useEffect hook to fetch folder names when the component mounts
    useEffect(() => {
        fetchFolderNames();
    }, []);

    return (
        <>
            <div className="position-relative" style={{ height: "100vh" }}>
                <div
                    id="myButtons"
                    className="position-absolute top-50 start-50 translate-middle"
                >
                    {/* Conditionally render the input field */}
                    {showInputField && (
                        <input
                            type="text"
                            value={newButtonLabel}
                            onChange={(e) => setNewButtonLabel(e.target.value)}
                        />
                    )}
                    {/* Button to add a new button */}
                    <button
                        type="button"
                        className="btn btn-primary round-2"
                        onClick={() => {
                            setShowInputField(true); // Show the input field when the button is clicked
                            addNewButton();
                        }}
                    >
                        +
                    </button>
                    <Link to="/build">
                        {/* Step 4: Map through the buttons state to render buttons */}
                        {buttons.map((button, index) => (
                            <button
                                key={index}
                                type="button"
                                className="btn btn-primary round-2"
                                onClick={() => TeamSelect(button.label)}
                            >
                                {button.label}
                            </button>
                        ))}</Link>
                </div>
            </div>

            <Outlet />
        </>
    );
};

export default Home;