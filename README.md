# let's learn Server side coding
We Will try to create a Server from Scratch : first locally and then hosting into cloud. Then We will consume the web service in our app.

## Installation :
-- Node 

-- NPM (node package modules)

    https://nodejs.org/en/

-- sublime text for coding or Atom.

-- Microsoft "Visual Studio Code" - preferred for coding, having in-built javascript auto-completion. (Preferred)

     https://code.visualstudio.com/


-- Intialise package.json 

    npm init
    npm install express // install express
    npm i body-parser // used for capturing the body of api calls
    npm i morgan // to track the api requests
    npm i mysql // to handle mysql database
      
## create a local mysql database 

#### step 1: Install mysql:
  
      brew install mysql 
      
#### step 2: run mysql:

Stop all :

        sudo brew services stop mysql
Start again:

	brew services start mysql


#### step 3: Install Sequel Pro:
   
    https://sequelpro.com/download

#### step 4: Open sequel pro and create a brand new database:

<img width="950" alt="screen shot 2018-04-22 at 8 41 05 pm" src="https://user-images.githubusercontent.com/10649284/39222894-bfc4002e-485c-11e8-8d24-30ee47d41606.png">
<img width="465" alt="screen shot 2018-04-22 at 8 43 01 pm" src="https://user-images.githubusercontent.com/10649284/39222895-bfeaf314-485c-11e8-99e7-0cbd1b7a4948.png">
<img width="1069" alt="screen shot 2018-04-22 at 8 45 08 pm" src="https://user-images.githubusercontent.com/10649284/39222896-c0151fc2-485c-11e8-8a9d-c57a24c74f45.png">
<img width="1067" alt="screen shot 2018-04-22 at 9 19 52 pm" src="https://user-images.githubusercontent.com/10649284/39222897-c03e07b6-485c-11e8-8b2f-956398ac508f.png">
<img width="555" alt="screen shot 2018-04-22 at 9 20 03 pm" src="https://user-images.githubusercontent.com/10649284/39222898-c06d48d2-485c-11e8-860e-c40624b7b7cc.png">

#### If you are facing any connection problem like that
<img width="952" alt="screen shot 2018-04-22 at 5 16 04 pm" src="https://user-images.githubusercontent.com/10649284/39222918-df004bb4-485c-11e8-9985-fe750be8c0af.png">

#### do step 2: run mysql again.


## Phase 1 : Create a Local Server :

Let's create app.js to create a local server : 

    // load our application server using express

	const express = require('express')
	const app = express()
	const morgan = require('morgan')
	const mysql = require('mysql')
	const bodyParser = require('body-parser')

	app.use(morgan('short'))
	app.use(express.static('./public')) // folder name
	app.use(bodyParser.urlencoded({ extended: false }))

	app.use(bodyParser.json({
	  type: "*/*"
	}));

	const connection = mysql.createConnection({
	  host: 'localhost',
	  user:  'root',
	  database: 'mysql_test'
	})

	const pool = mysql.createPool({
	  connectionLimit: 15,
	  host: 'localhost',
	  user:  'root',
	  database: 'mysql_test'
	})

	function getConnection() {
	  return pool
	}

	app.get('/', (req, res) => {
	  console.log("responding to root route")
	  res.send("Hello world")
	})

	app.get('/test', (req, res) => {
	  var user1 = { "firstName": "Ashis", "lastName": "Laha" }
	  var user2 = { "firstName": "Kunal", "lastName": "Pradhan"}
	  res.json([user1, user2])
	})

	const PORT = process.env.PORT || 3000
	app.listen(PORT, () => {
	  console.log('server is up and listening on port: '+ PORT)
	})

	// GET all users
	app.get('/users', (req, res) => {
	  const queryString = "select * from users"
	  getConnection().query(queryString, (err, results, fields) => {
	    if (err) {
	      console.log('Having some error'+ err)
	      res.sendStatus(500)
	      res.end()
	    } else {
	      //res.json(results)
	      const mapedUsers = results.map((eachResult) => {
		return { "id":eachResult.id, "firstName": eachResult.first_name, lastName: eachResult.last_name }
	      })
	      res.json(mapedUsers)
	    }
	  })
	})

	// GET an one user by user_id
	app.get('/user/:id', (req, res) => {
	  const userId = req.params.id
	  console.log('fetching user data'+ userId)
	  const queryString = "select * from users where id = ?"
	  getConnection().query(queryString, [userId], (error, results, fields) => {
	    if (error) {
	      console.log("having some fetching error: "+error)
	      res.sendStatus(500)
	      res.end()
	    } else {
	      const mappedUser = results.map((eachResult) => {
		return { "id":eachResult.id, "firstName": eachResult.first_name, lastName: eachResult.last_name }
	      })
	      res.json(mappedUser)
	    }
	  })
	})


	// create a new user record
	app.post('/user_create', (req, res) => {
	  const firstName = req.body.first_name
	  const lastName = req.body.last_name
	  const queryString = "insert into users (first_name, last_name) values (?,?)"
	  console.log(firstName, lastName)

	  getConnection().query(queryString, [firstName, lastName], (err, results, fields) => {
	    if (err) {
	      console.log("having some error to create a new user" + err)
	      res.sendStatus(500)
	      res.end()
	      return
	    }
	    console.log('new user insertion is success')
	    res.json({success: true})
	    res.end()
	  })
	})

	// update a user record
	app.post('/update_user', (req, res) => {
	  const firstName = req.body.first_name
	  const lastName = req.body.last_name
	  const id = req.body.id
	  const queryString = "update users set first_name = ?, last_name= ? where id = ?"
	  console.log(firstName, lastName, id)

	  getConnection().query(queryString, [firstName, lastName, id], (err, results, fields) => {
	    if (err) {
	      console.log("having some error to update user" + err)
	      res.sendStatus(500)
	      res.end()
	      return
	    }
	    console.log('user recorded updated')
	    res.json({success: true})
	    res.end()
	  })
	})

	// delete a record
	app.post('/delete_user/:id', (req, res) => {
	  const id = req.params.id
	  const queryString = "delete from users where id = ?"
	  getConnection().query(queryString, [id], (err, results, fields) => {
	    if (err) {
	      console.log("having some error to create a new user" + err)
	      res.sendStatus(500)
	      res.end()
	      return
	    }
	    console.log('user has been deleted')
	    res.json({success: true})
	    res.end()
	  })
	})

Run it on terminal 
      
      $node app.js
      $nodemon app.js
 
 ### Output:
 
 <img width="414" alt="screen shot 2018-04-22 at 9 32 16 am" src="https://user-images.githubusercontent.com/10649284/39091369-492422e4-4610-11e8-97f0-0b40cf235a9b.png">


<b> Use nodemon (demon server) which helps us to run the server without quiting and running it again, just save the new changes. </b>
      
      $sudo npm install -g nodemon
      

# added native iOS app:

	App can consume the local service and performing the following operations:
	
	(1). Fetch all users (GET call)
	(2). Fetch a particular user using user_id (GET Call)
	(3). Update a user record with new data (POST call)
	(4). Add a new User (POST call)
	(5). Delete a user. (POST/DELETE call)
	
# To stop the server, 
      
      use (control + c) 
      
      
# Host the local service into cloud using heroku:

Use the following steps to host the local service into heroku:

<img width="839" alt="screen shot 2018-06-03 at 9 03 50 am" src="https://user-images.githubusercontent.com/10649284/40883602-d675b818-671e-11e8-8e9f-b6f4b5a3f6c6.png">

	(1). Create a heroku account 

	(2). create an heroku application under your account 
	     (like: "explore-world", or leave it empty so that heroku provide some name )

	(3). follow the deployment process: install  heroku CLI (command line interface)

	(4). Do login in terminal: $heroku login 

	(5). Verify the versions of node, nom, git: $node - - version, $nom - - version, $git - -  version

	(6). If you have some apps in heroku: check using $heroku apps 
	     (or Create a new heroku application: $heroku create or step-2)

	(7).  $git init  (initialize the git) 
	      ( If you are doing on new project, do git clone: $heroku git:clone -a explore-world, as we already have an app, 		       no need to clone it again)

	(8).  check the status: $git status

	(9). Add all the changes: $git add .

	(10). commit all the changed files: $git commit -m “some commit messages”

	(11). Push the code:  git push heroku master (sometimes you need to add git remote if it is not added )

	(12). For debugging: $heroku logs - - tail

	(13). Define a Procfile to say heroku what application to load ( web: node app.js )

	(14). Do one more push to cloud, everything is up. 

	(16). Adding some add-ons like clearDB mysql data-base: $heroku addons:create cleardb:ignite

	(17). Run the config: $heroku config (you will get the clearDB database url )

## clearDB database specifications: 

	CLEARDB_DATABASE_URL: mysql:// b4964d1079f327:8c3f6a93@us-cdbr-iron-east-04.cleardb.net/heroku_178a72b8dd50777?reconnect=true

	User: b4964d1079f327
	Password: 8c3f6a93
	Host: us-cdbr-iron-east-04.cleardb.net
	Database: heroku_178a72b8dd50777


<img width="477" alt="screen shot 2018-06-03 at 10 41 43 am" src="https://user-images.githubusercontent.com/10649284/40883600-d1c74908-671e-11e8-82f5-b20a8a6c15d0.png">

<img width="883" alt="screen shot 2018-06-03 at 9 53 53 am" src="https://user-images.githubusercontent.com/10649284/40883601-d407d0e8-671e-11e8-9feb-111de3ce51af.png">


## End point:

    https://explore-world.herokuapp.com
    
 <img width="468" alt="screen shot 2018-06-03 at 11 13 19 am" src="https://user-images.githubusercontent.com/10649284/40883616-293db672-671f-11e8-98ab-46946a893a3c.png">  



