const db = require('./db');

async function getAllBooks() {
	try {
		const [books] = await db.query('SELECT * FROM books limit 3');
		console.log('Alle Bücher:', books);
		return books;
	} catch (error) {
		console.error('Fehler beim Lesen:', error.message);
	}
}

// Buch nach ID suchen
async function getBookById(bookId) {
	try {
		const [books] = await db.query(
		'SELECT * FROM books WHERE id = ?',
		[bookId]
		);
		return books[0];
	} catch (error) {
		console.error('Fehler:', error.message);
	}
}

getAllBooks();

