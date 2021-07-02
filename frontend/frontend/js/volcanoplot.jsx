import Plot from 'react-plotly.js';
import axios from 'axios';
import React, { useState, useEffect } from 'react';


export default function Volcano() {

    const [localData, setData] = useState({ hits: [] });
    const [error, setError] = useState(null);
    const [isLoaded, setIsLoaded] = useState(false);
    const [currentItem, setItem] = useState("");


    useEffect(() => {
        fetch("http://localhost:8001/api")
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
          )
      }, []);

    return <div>
              {
          currentItem != "" ? <h1>Selected Gene: {currentItem}</h1> : <div/>
      }
        {isLoaded ? <Plot
        data={[
          {
            x: localData.logFC,
            y: localData.FDR,
            type: 'scatter',
            mode: 'markers',    
            text: localData["Gene Symbol"],
            marker: {color: 'red'},
          },
        ]}
        layout={ {width: 1000, height: 1000, title: 'Test Volcano'} }
        onClick={(e) => {console.log("onClick",e.points[0].text); setItem(e.points[0].text);}}
        onHover={(e) => console.log("onHover",e.points[0].text)}
      /> : <h1>Loading...</h1>}
    </div>
} 