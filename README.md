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
