const { MongoClient } = require('mongodb');

const uri = "mongodb://localhost/?retryWrites=true&w=majority";
const client = new MongoClient(uri);

async function connect() {
    try {
        await client.connect();
        console.log("Verbunden mit MongoDB!");
        
        const database = client.db('library');
        const collection = database.collection('books');
        
        // ... Operationen hier
		
		const newBook = {
    title: "The Hobbit",
    author: "J.R.R. Tolkien",
    isbn: "978-0547928227",
    publicationYear: 1937,
    tags: ["fantasy", "adventure"]
};

const result = await collection.insertOne(newBook);
console.log('Eingefügt mit ID:', result.insertedId);

// Mehrere Dokumente einfügen
const books = [
    { title: "Book 1", author: "Author 1" },
    { title: "Book 2", author: "Author 2" }
];

const results = await collection.insertMany(books);
console.log('Eingefügte IDs:', results.insertedIds);


        
    } finally {
        await client.close();
    }
}

connect();
