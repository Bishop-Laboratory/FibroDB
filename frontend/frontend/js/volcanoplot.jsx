import Plot from 'react-plotly.js';
import axios from 'axios';
import React, { useState, useEffect } from 'react';
import { DataGrid } from '@material-ui/data-grid';
import { SERVER_BASE } from './constants';
import GenePlot, { GenericForm, GenePlotRaw } from './GenePlot';
import { makeStyles } from '@material-ui/styles';
import SearchBar from "material-ui-search-bar";
import styled from "styled-components";


const studies = ["GSE149413", "GSE97829", "GSE123018", "GSE140523"];




export default function Volcano() {
  const [originalData, setOrigin] = useState([{ "id": 1, "gene_id": "Loading", "study_id": "Loading", "pval": 0, fc: 0 }]);
  const [localData, setData] = useState([]);
  const [error, setError] = useState(null);
  const [isLoaded, setIsLoaded] = useState(false);
  const [currentItem, setItem] = useState("");
  const [studiesChoice, setChoice] = useState(null);
  


  function handleChange(newValue) {
    setItem(newValue);
  }

  useEffect(() => {
    console.log("CURRENTITEM", currentItem);
  }, [currentItem]);

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

          setData(localArray);
          
          result = result.sort(function(a,b){ if (a["gene_id"] < b["gene_id"]) return -1;
          if (a["gene_id"] > b["gene_id"]) return 1;
          return 0;})


          let processedArray = [];

          for(let i= 0; i<result.length; i = i +2){
            processedArray.push({
              id: result[i]["gene_id"],
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
        }
      )
  }, []);

  
  

  return <div>
    {isLoaded ? <div style={{ display: 'flex', height: '50%'}}>
      <GenericForm isMulti={true} inputLabel="Studies" forminputs={studies} handleFormChange={setChoice} />
      <Plot
      extra={currentItem}
      data={studies.map((studychoice,index) => 
        { console.log("selectedElem",currentItem);
          return ({
          x: localData[studies.indexOf(studychoice)].FC,
          y: localData[studies.indexOf(studychoice)].logP,
          type: 'scattergl',
          mode: 'markers',
          name: studychoice,
          text: localData[studies.indexOf(studychoice)]["Gene Symbol"],
          marker: { color: localData[studies.indexOf(studychoice)]["Gene Symbol"].map((elem) => (elem === currentItem) 
                  ? 'rgb(0,255,0,0,1)' 
                  :  (studychoice === studies[0]) 
                  ? 'rgba(255,0,0,0.1)' 
                  : 'rgba(0,0,255,0.1)')}
        })
        }).filter((elem, index) => studiesChoice ? studiesChoice.includes(studies[index]) : true)}
      layout={{ width: '45vw', height: '45vh'}}

      onClick={(e) => { console.log("onClick", e.points[0].text); setItem(e.points[0].text); setOrigin(
        [...originalData.filter(item => item["gene_id"] === e.points[0].text), 
        ...originalData.filter(item => item["gene_id"] !== e.points[0].text)
      ]
      );}}
      />
      <TableView tabledata={originalData} onChange={handleChange} selected={currentItem} /></div> : <h1>Loading...</h1>}
      <br/>
      <br/>
      
      <GenePlotRaw genename={currentItem} studiesChoice={studiesChoice ? studiesChoice : studies}/>
  </div>
}


const useStyles = makeStyles({
  root: {
    '& .super-app-theme-Filled': {
      backgroundColor: 'rgba(224, 183, 60, 0.55)',
      color: '#1a3e72',
      fontWeight: '600',
    },
    '& .super-app.negative': {
      backgroundColor: 'rgba(157, 255, 118, 0.49)',
      color: '#1a3e72',
      fontWeight: '600',
    },
    '& .super-app.positive': {
      backgroundColor: '#d47483',
      color: '#1a3e72',
      fontWeight: '600',
    },
  },
});

function TableView({tabledata, onChange, selected}) {
  const [filtereddata, setRows] = useState(tabledata);
  const [searchterm, setTerm] = useState("");

  const [select, setSelection] = useState(selected);
  const classes = useStyles();

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
  const handleChange = (newval) => {
    const filteredRows = tabledata.filter((row) => {
      const rowval = row.gene_id.toLowerCase();
      return rowval.includes(newval.toLowerCase());
    });
    setRows(filteredRows);
  }
  const cancelSearch = () => {
    setSearched("");
    requestSearch(searchterm);
  };
  const handleRowSelection = (e) => {
    onChange(e[0]);
  }

  useEffect(() => {
    setRows(tabledata)
  }, [tabledata]);

  useEffect(() => {
    setSelection(selected);
    console.log(selected);
  }, [selected]);


  return (
    <div className={classes.root} style={{width:"50%", height:"100%"}}>
    <SearchBar value={searchterm} onChange={(newval) => handleChange(newval)} onCancelSearch={() => cancelSearch} />
    <DataGrid rows={filtereddata} columns={columns} pageSize={10} onSelectionModelChange={handleRowSelection} 
    getRowClassName={(params) =>
     {
       return select === params.row.gene_id ? `Mui-selected` : `notSelected`;
     }
    }
    selectionModel={[select]}
    />
    </div>
  )

}