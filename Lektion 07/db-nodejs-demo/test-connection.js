const db = require('./db');
async function testConnection() {
	try {
		const [rows] = await db.query('SELECT 1 + 1 AS result');
		console.log('Datenbankverbindung erfolgreich!');
		console.log('Test Query Result:', rows[0].result);
	} catch (error) {
		console.error('Fehler bei Datenbankverbindung:', error.message);
	} finally {
		process.exit();
	}
}

testConnection();
