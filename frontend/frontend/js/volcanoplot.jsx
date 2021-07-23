import Plot from 'react-plotly.js';
import axios from 'axios';
import React, { useState, useEffect } from 'react';
import { DataGrid } from '@material-ui/data-grid';
import { SERVER_BASE } from './constants';
import { GenericForm } from './GenePlot';


const studies = ["GSE149413", "GSE97829"];

export default function Volcano() {
  const [originalData, setOrigin] = useState([{ "id": 1, "gene_id": "Loading", "study_id": "Loading", "pval": 0, fc: 0 }]);
  const [localData, setData] = useState([]);
  const [error, setError] = useState(null);
  const [isLoaded, setIsLoaded] = useState(false);
  const [currentItem, setItem] = useState("");
  const [studiesChoice, setChoice] = useState(null);
  


  useEffect(() => {
    fetch(SERVER_BASE + "deg")
      .then(res => res.json())
      .then(
        (result) => {
          
          result.forEach(function (element, index) {
            element.id = index;
          });
          


          const result2 = {
            'FC': result.map(elem => elem['fc']),
            'logP': result.map(elem => -1 * Math.log(elem['pval'])),
            'Gene Symbol': result.map(elem => elem['gene_id']),
            'Study Id': result.map(elem => elem['study_id'])
          }

          let localArray = [];
          for(let i = 0; i < studies.length; i++) {
            localArray.push({
              'FC': result2.FC.filter((val, index) => result2["Study Id"][index] === studies[i]),
              'logP': result2.logP.filter((val, index) => result2["Study Id"][index] === studies[i]),
              'Gene Symbol': result2["Gene Symbol"].filter((val, index) => result2["Study Id"][index] === studies[i]),
            });
          }

          console.log(localArray);
          setData(localArray);
          
          result = result.sort(function(a,b){ if (a["gene_id"] < b["gene_id"]) return -1;
          if (a["gene_id"] > b["gene_id"]) return 1;
          return 0;})

          console.log(result.slice(0,2));
          let processedArray = [];

          for(let i= 0; i<result.length; i = i +2){
            processedArray.push({
              id: i,
              gene_id : result[i]["gene_id"],
              pval0: result[i]["study_id"] == studies[0] ? result[i]["pval"] : result[i+1]["pval"],
              pval1: result[i]["study_id"] == studies[1] ? result[i]["pval"] : result[i+1]["pval"],
              fc0: result[i]["study_id"] == studies[0] ? result[i]["fc"] : result[i+1]["fc"],
              fc1: result[i]["study_id"] == studies[1] ? result[i]["fc"] : result[i+1]["fc"]
            });
          }

          setOrigin(processedArray);
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
      <GenericForm isMulti={false} inputLabel="Studies" forminputs={studies} handleFormChange={setChoice} />
      <Plot
      data={studies.map((studychoice,index) => 
        { return ({
          x: localData[index].FC,
          y: localData[index].logP,
          type: 'scatter',
          mode: 'markers',
          name: studychoice,
          text: localData[index]["Gene Symbol"],
          marker: { color: studychoice === studies[0] ? 'rgba(255,0,0,0.5)' : 'rgba(0,0,255,0.5)' }
        })
        }).filter((elem, index) => studiesChoice ? studies[index] == studiesChoice : true)}
      layout={{ width: 1000, height: 1000, title: 'Volcano Plot' }}

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
    { field: 'pval0', headerName: 'p Value for ' + studies[0], width: 300 },
    {
      field: "fc0", headerName: "fold change for " + studies[0], width: 300
    },
    { field: 'pval1', headerName: 'p Value for ' + studies[1], width: 300 },
    {
      field: "fc1", headerName: "fold change for " + studies[1], width: 300
    },
  ]
  console.log(tabledata);
  return (
    <DataGrid rows={tabledata["tabledata"]} columns={columns} pageSize={10} />
  )
}