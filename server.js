const express = require('express');
const mysql = require('mysql2');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'login.html'));
});

app.get('/login', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'login.html'));
});

const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'sql', 
    database: 'alumni_db',
    port: 3307, 
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

db.getConnection((err, connection) => {
    if (err) {
        console.error('❌ DATABASE CONNECTION FAILED:', err.message);
    } else {
        console.log('✅ Connected to MySQL database successfully!');
        connection.release();
    }
});

app.post('/api/login', (req, res) => {
    const { username, password } = req.body;
    const query = 'SELECT * FROM users WHERE username = ? AND password = ?';
    
    db.query(query, [username, password], (err, results) => {
        if (err) {
            console.error('❌ LOGIN ERROR:', err.message);
            return res.status(500).json({ error: 'Database error during login.' });
        }

        if (results.length > 0) {
            const user = results[0];
            res.json({
                message: "Login successful!",
                username: user.username,
                role_id: user.role_id 
            });
        } else {
            res.status(401).json({ error: 'Invalid username or password' });
        }
    });
});

// Updated GET route to exclude soft-deleted records
app.get('/api/alumni', (req, res) => {
    const query = `
        SELECT a.*, p.program_name 
        FROM alumni a 
        LEFT JOIN programs p ON a.program_id = p.program_id
        WHERE a.is_deleted = 0 OR a.is_deleted IS NULL
    `;
    db.query(query, (err, results) => {
        if (err) {
            console.error('❌ FETCH ERROR:', err.message);
            return res.status(500).json({ error: 'Failed to retrieve alumni records.' });
        }
        res.json(results);
    });
});

app.post('/api/alumni', (req, res) => {
    const { 
        alumni_id, student_id, first_name, middle_name, last_name, 
        gender, date_of_birth, email, contact_number, address, program_id, batch_year 
    } = req.body;

    const query = `
        INSERT INTO alumni (
            alumni_id, student_id, first_name, middle_name, last_name, 
            gender, date_of_birth, email, contact_number, address, program_id, batch_year
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    
    db.query(
        query, 
        [
            alumni_id || null, student_id, first_name, middle_name || null, last_name, 
            gender || null, date_of_birth || null, email, contact_number || null, 
            address, program_id, batch_year
        ], 
        (err, results) => {
            if (err) {
                console.error('❌ INSERT ERROR:', err.message);
                return res.status(500).json({ error: 'Database error or email/student ID already registered.' });
            }
            res.status(201).json({ message: 'Alumnus registered successfully!', alumniId: results.insertId });
        }
    );
});

app.put('/api/alumni/:id', (req, res) => {
    const studentId = req.params.id;
    const { 
        first_name, middle_name, last_name, gender, 
        date_of_birth, email, contact_number, address, 
        program_id, batch_year 
    } = req.body;

    const query = `
        UPDATE alumni SET 
            first_name = ?, middle_name = ?, last_name = ?, gender = ?, 
            date_of_birth = ?, email = ?, contact_number = ?, address = ?, 
            program_id = ?, batch_year = ?
        WHERE student_id = ?
    `;

    db.query(
        query, 
        [first_name, middle_name || null, last_name, gender || null, date_of_birth || null, email, contact_number || null, address, program_id, batch_year, studentId],
        (err) => {
            if (err) {
                console.error('❌ UPDATE ERROR:', err.message);
                return res.status(500).json({ error: 'Failed to update alumnus record.' });
            }
            res.json({ message: 'Alumnus updated successfully!' });
        }
    );
});

app.patch('/api/alumni/:id/status', (req, res) => {
    const studentId = req.params.id;
    const { status } = req.body;

    const query = `UPDATE alumni SET current_status = ? WHERE student_id = ?`;
    db.query(query, [status, studentId], (err) => {
        if (err) {
            console.error('❌ STATUS UPDATE ERROR:', err.message);
            return res.status(500).json({ error: 'Failed to update status.' });
        }
        res.json({ message: `Alumnus status changed to ${status} successfully!` });
    });
});


app.patch('/api/alumni/:id/soft-delete', (req, res) => {
    const studentId = req.params.id;
    
    const query = `UPDATE alumni SET is_deleted = 1 WHERE student_id = ?`;
    db.query(query, [studentId], (err) => {
        if (err) {
            console.error('❌ SOFT DELETE ERROR:', err.message);
            return res.status(500).json({ error: 'Failed to soft delete record.' });
        }
        res.json({ message: 'Alumnus record archived successfully!' });
    });
});

app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    const query = 'SELECT * FROM users WHERE username = ?';
    db.query(query, [username], (err, results) => {
        if (err) {
            console.error('❌ LOGIN ERROR:', err.message);
            return res.status(500).json({ error: 'Database error during login.' });
        }

        if (results.length === 0) {
            return res.status(401).json({ error: 'Invalid username or password' });
        }

        const user = results[0];

        if (user.status === 'Inactive' || user.current_status === 'Inactive') {
            return res.status(403).json({ error: 'This account is inactive. Access denied.' });
        }

        if (password !== user.password) {
            return res.status(401).json({ error: 'Invalid username or password' });
        }

        res.json({
            success: true,
            message: "Login successful!",
            username: user.username,
            role_id: user.role_id 
        });
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});