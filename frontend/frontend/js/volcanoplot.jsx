import Plot from 'react-plotly.js';
import axios from 'axios';
import React, { useState, useEffect } from 'react';
import { DataGrid } from '@material-ui/data-grid';

export default function Volcano() {
  const [originalData, setOrigin] = useState([{ "id": 1, "gene_id": "Loading", "study_id": "Loading", "pval": 0, fc: 0 }]);
  const [localData, setData] = useState({});
  const [error, setError] = useState(null);
  const [isLoaded, setIsLoaded] = useState(false);
  const [currentItem, setItem] = useState("");




  useEffect(() => {
    fetch("http://localhost:5000/api-v1/deg")
      .then(res => res.json())
      .then(
        (result) => {
          setIsLoaded(true);
          console.log("Got Data");
          console.log(result);
          result.forEach(function (element, index) {
            element.id = index;
          });
          setOrigin(result);

          const result2 = {
            'FC': result.map(elem => elem['fc']),
            'logP': result.map(elem => -1 * Math.log(elem['pval'])),
            'Gene Symbol': result.map(elem => elem['gene_id'])
          }
          console.log(result2);
          setData(result2);
        },
        (error) => {
          setIsLoaded(true);
          console.log(error);
        }
      )
  }, []);

  return <div>
    {
      currentItem != "" ? <h1>Selected Gene: {currentItem}</h1> : <div />
    }
    {isLoaded ? <div><Plot
      data={[
        {
          x: localData.FC,
          y: localData.logP,
          type: 'scatter',
          mode: 'markers',
          text: localData["Gene Symbol"],
          marker: { color: 'red' },
        },
      ]}
      layout={{ width: 1000, height: 1000, title: 'Test Volcano' }}

      onClick={(e) => { console.log("onClick", e.points[0].text); setItem(e.points[0].text); setOrigin(
        [...originalData.filter(item => item["gene_id"] === e.points[0].text), 
        ...originalData.filter(item => item["gene_id"] !== e.points[0].text)
      ]
      );}}
      onHover={(e) => console.log("onHover", e.points[0].text)}
      /><TableView tabledata={originalData} /></div> : <h1>Loading...</h1>}
  </div>
}


function TableView(tabledata) {
  const columns = [
    { field: 'gene_id', headerName: 'Gene ID', width: 300 },
    { field: 'study_id', headerName: 'Study ID', width: 300 },
    { field: 'pval', headerName: 'p Value', width: 300 },
    {
      field: "fc", headerName: "fold change", width: 300
    }
  ]
  console.log(tabledata);
  return (
    <DataGrid rows={tabledata["tabledata"]} columns={columns} pageSize={5} />
  )
}