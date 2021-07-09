import React from 'react';
import {
    BrowserRouter as Router,
    Switch,
    Route,
    Link,
    useParams
  } from "react-router-dom";
  import {Menu} from './components/pageview.jsx';
  import Plot from 'react-plotly.js';
  import Volcano from './volcanoplot.jsx';
  import GenePlot from './GenePlot.jsx';
  import SearchForm from './SearchForm.jsx';



  export default function App() {
    return (
      <Router>
        <div>
          <nav>
            <Menu>
              <div>
                <Link to="/">Home</Link>
              </div>
              <div>
                <Link to="/results">Results Overview</Link>
              </div>
              <div>
                <Link to="/genes">Genes Overview</Link>
              </div>
              <div>
                <Link to="/about">About</Link>
              </div>
              <div>
                <Link to="/downloads">Downloads</Link>
              </div>
              <div>
                <Link to="/help">Help</Link>
              </div>
            </Menu>
          </nav>
  
          <Switch>
            <Route exact path="/">
              <Home />
            </Route>
            <Route path="/results">
              <Results />
            </Route>
            <Route path="/genes/:geneid">
              <Genes />
            </Route>
            <Route path="/about">
              <About />
            </Route>
            <Route path="/downloads">
              <TBA />
            </Route>
            <Route path="/help">
              <TBA />
            </Route>
          </Switch>
        </div>
      </Router>
    );
  }
  
  function Home() {
    return <div><h2>Welcome!</h2><SearchForm/></div>;
  }
  
  function About() {
    return <h2>About</h2>;
  }
  
  function Results() {
    return <div>
        <h2>Results</h2>
      <Volcano/>
    </div>;
  }

  function Genes() {
    let { geneid } = useParams();
    return <div>
        <h2>Genes</h2>
      <GenePlot genename={geneid}/>
    </div>;
  }

  function TBA() {
    return <div>
      <h2> To Be Added. </h2>
    </div>
  }