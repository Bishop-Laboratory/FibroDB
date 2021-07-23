import Plot from 'react-plotly.js';
import axios from 'axios';
import React, { useState, useEffect } from 'react';
import { DataGrid } from '@material-ui/data-grid';
import { SERVER_BASE } from './constants';
import { GenericForm } from './GenePlot';

export default function Volcano() {
  const [originalData, setOrigin] = useState([{ "id": 1, "gene_id": "Loading", "study_id": "Loading", "pval": 0, fc: 0 }]);
  const [localData, setData] = useState({});
  const [error, setError] = useState(null);
  const [isLoaded, setIsLoaded] = useState(false);
  const [currentItem, setItem] = useState("");
  const [studiesChoice, setChoice] = useState([]);



  useEffect(() => {
    fetch(SERVER_BASE + "deg")
      .then(res => res.json())
      .then(
        (result) => {
          
          result.forEach(function (element, index) {
            element.id = index;
          });
          setOrigin(result);


          const result2 = {
            'FC': result.map(elem => elem['fc']),
            'logP': result.map(elem => -1 * Math.log(elem['pval'])),
            'Gene Symbol': result.map(elem => elem['gene_id']),
            'Study Id': result.map(elem => elem['study_id'])
          }
          console.log(result2);
          setData(result2);
          setIsLoaded(true);
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
    {isLoaded ? <div>
      <GenericForm isMulti={true} inputLabel="Studies" forminputs={[
"GSE149413", "GSE97829"]} handleFormChange={setChoice} />
      <Plot
      data={[
        {
          x: localData.FC.filter((elem, index) =>  studiesChoice.includes(localData["Study Id"][index])),
          y: localData.logP.filter((elem, index) =>  studiesChoice.includes(localData["Study Id"][index])),
          type: 'scatter',
          mode: 'markers',
          text: localData["Gene Symbol"],
          marker: { color: 'red' },
        },
      ]}
      layout={{ width: 1000, height: 1000, title: 'Volcano Plot' }}

      onClick={(e) => { console.log("onClick", e.points[0].text); setItem(e.points[0].text); setOrigin(
        [...originalData.filter(item => item["gene_id"] === e.points[0].text), 
        ...originalData.filter(item => item["gene_id"] !== e.points[0].text)
      ]
      );}}
      onHover={(e) => console.log("onHover", e.points[0].text)}
      /><TableView tabledata={originalData.filter((elem, index) =>  studiesChoice.includes(localData["Study Id"][index]))} /></div> : <h1>Loading...</h1>}
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
    <DataGrid rows={tabledata["tabledata"]} columns={columns} pageSize={10} />
  )
}