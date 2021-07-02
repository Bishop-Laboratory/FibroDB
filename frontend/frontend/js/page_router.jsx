import React from 'react';
import {
    BrowserRouter as Router,
    Switch,
    Route,
    Link
  } from "react-router-dom";
  import {Menu} from './components/pageview.jsx';
  import Plot from 'react-plotly.js';
  import Volcano from './volcanoplot.jsx';
  import SearchForm from './SearchForm.jsx';
  export default function App() {
    return (
      <Router>
        <div>
          <nav>
            <Menu>
              <div>
                <Link to="/">Home2</Link>
              </div>
              <div>
                <Link to="/search-genes">Search-Genes</Link>
              </div>
              <div>
                <Link to="/about">About</Link>
              </div>
            </Menu>
          </nav>
  
          <Switch>
            <Route exact path="/">
              <Home />
            </Route>
            <Route path="/search-genes">
              <Search />
            </Route>
            <Route path="/about">
              <About />
            </Route>
          </Switch>
        </div>
      </Router>
    );
  }
  
  function Home() {
    return <div><h2>Home</h2><SearchForm/></div>;
  }
  
  function About() {
    return <h2>About</h2>;
  }
  
  function Search() {
    return <div>
        <h2>Search</h2>
      <Volcano/>
    </div>;
  }