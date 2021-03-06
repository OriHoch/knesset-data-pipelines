# Knesset data pipelines

Knesset data scrapers and data sync

Uses the [datapackage pipelines framework](https://github.com/frictionlessdata/datapackage-pipelines) to scrape Knesset data and produce JSON+CSV files for useful queries.

This flow is executed periodically and resulting files are copied to Google Cloud Storage for use by the static web site generator and (in the future) oknesset APIs.


## Contributing

Looking to contribute? check out the [Help Wanted Issues](https://github.com/hasadna/knesset-data-pipelines/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) or the [Noob Friendly Issues](https://github.com/hasadna/knesset-data-pipelines/issues?q=is%3Aissue+is%3Aopen+label%3A%22noob+friendly%22) for some ideas.

Useful resources for getting acquainted:
* [DPP](https://github.com/frictionlessdata/datapackage-pipelines) documentation
* [Code](https://github.com/OriHoch/knesset-data-k8s) for the periodic execution component
* [Info](http://main.knesset.gov.il/Activity/Info/Pages/Databases.aspx) on available data from the Knesset site
* Living [document](https://docs.google.com/document/d/1eeQRrpGYuEJKAAtShPbjFn6i2f_UmQgg1caMTEs93ic/edit) with short list of ongoing project activities


## Quickstart using Jupyter notebooks and Dataflows

Follow this method to get started quickly with exploration, processing and testing of the knesset data.

Clone knesset-data-pipelines

```
git clone https://github.com/hasadna/knesset-data-pipelines.git
```

Change directory to the knesset-data-pipelines project root

```
cd knesset-data-pipelines
```

You can run the Jupyter notebook server using Docker or locally with python3

##### Running the Jupyter notebook server using Docker

Install Docker for [Windows](https://store.docker.com/editions/community/docker-ce-desktop-windows),
[Mac](https://store.docker.com/editions/community/docker-ce-desktop-mac) or [Linux](https://docs.docker.com/install/)

Start The knesset-data-pipelines Jupyter server with configuration suitable for local development:

```
docker run -it -p 8888:8888 -v `pwd`:/pipelines \
           orihoch/knesset-data-pipelines-jupyter \
           start-notebook.sh --NotebookApp.token= \
                             --NotebookApp.notebook_dir=jupyter-notebooks
```

##### Running the Jupyter notebook server locally with Python3

Install pipenv: https://pipenv.readthedocs.io/en/latest/install/#installing-pipenv

Install compatible pip version:

```
python3 -m pip install --user 'pip<18.1'
```

Install project dependencies

```
pipenv install
pipenv run python3 -m pip install -e .
```

Run the Jupyter notebook server

```
pipenv run jupyter notebook --NotebookApp.notebook_dir=jupyter-notebooks
```

##### Using the Jupyter notebooks

Browser should open automatically, if it doesn't, check the output log, it should contain the URL to open

On the left sidebar you should see the notebooks provided from knesset-data-pipelines, you are welcome to modify or add notebooks and open a pull request.

If you want to run some processing on the full set of data let us know and we can provide a server for you with all knesset data available locally.


## running the pipelines using docker

```
docker pull orihoch/knesset-data-pipelines
docker run -it --entrypoint bash -v `pwd`:/pipelines orihoch/knesset-data-pipelines
```

List the available pipelines

```
dpp
```

run a pipeline

```
dpp run <PIPELINE_ID>
```

You can usually fix permissions problems on the files by running inside the docker `chown -R 1000:1000 .`


## Running the pipelines locally

Install some dependencies (following works for latest version of Ubuntu):

```
sudo apt-get install -y python3.6 python3-pip python3.6-dev libleveldb-dev libleveldb1v5
sudo pip3 install pipenv
```

install the pipeline dependencies

```
pipenv install
```

activate the virtualenv

```
pipenv shell
```

Install the python module

```
pip install -e .
```

List the available pipelines

```
dpp
```

run a pipeline

```
dpp run <PIPELINE_ID>
```


## downloading the dataservices knesset data

The Knesset API is sometimes blocked / throttled from certain IPs.

To overcome this we provide the core data available for download so pipelines that process the data don't need to call the Knesset API directly.

You can set the `DATASERVICE_LOAD_FROM_URL=1` to enable download for pipelines that support it:

```
DATASERVICE_LOAD_FROM_URL=1 pipenv run dpp run ./committees/kns_committee
```


## dumping data to redash DB

This is used to populate the obudget redash at http://data.obudget.org/

To test locally, start a postgresql server:

```
docker run -d --rm --name postgresql -p 5432:5432 -e POSTGRES_PASSWORD=123456 postgres
```

Run the all package with dump.to_sql enabled

```
DPP_DB_ENGINE=postgresql://postgres:123456@localhost:5432/postgres pipenv run dpp run ./committees/all
```

Run the dump to db pipeline:

```
DPP_DB_ENGINE=postgresql://postgres:123456@localhost:5432/postgres dpp run ./knesset/dump_to_db
```

Start adminer to browse the data

```
docker run -d --name adminer -p 8080:8080 --link postgresql adminer
```

* Adminer is available at http://localhost:8080
  * system: postgresql, server: postgresql, username: postgres, password: 123456, database: postgres

Remove the containers when done

```
docker rm --force adminer postgresql
```
