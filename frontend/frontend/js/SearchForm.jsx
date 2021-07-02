import Plot from 'react-plotly.js';
import axios from 'axios';
import React, { useState, useEffect } from 'react';


export default function SearchForm() {

    const [searchTerm, setTerm] = useState("");
    const [localData, setData] = useState({ hits: [] });
    const [error, setError] = useState(null);
    const [isLoaded, setIsLoaded] = useState(false);


    const handleSubmit = (e) => {
        e.preventDefault();
        fetch("http://localhost:8001/info?name="+searchTerm)
              .then(res => res.json())
              .then(
                (result) => {
                  setIsLoaded(true);
                  setData(result);
                },
                // Note: it's important to handle errors here
                // instead of a catch() block so that we don't swallow
                // exceptions from actual bugs in components.
                (error) => {
                  setIsLoaded(true);
                  setError(error);
                }
              );
    }
    

    return <div>
        <form onSubmit={handleSubmit}>
        <input type="text" placeholder="SearchMe" value={searchTerm} onChange={(e) => setTerm(e.target.value)}/>
        </form>
        <h1>{searchTerm}</h1>
        <h2>{JSON.stringify(localData)}</h2>
    </div>
} 