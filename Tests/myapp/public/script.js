const express = require('express'); // Import Express.js
const app = express(); // Create an Express app
const port = process.env.PORT || 8080; // Use PORT from environment or default to 8080

// Middleware to serve static files from the 'public' directory
app.use(express.static('public'));

// Route to serve the main HTML file
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/public/index.html');
});

// Start the server
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
