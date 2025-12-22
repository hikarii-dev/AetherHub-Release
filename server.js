// Aether Hub v5.0 - Shared Key System
// One key for everyone, changes every 3 hours

const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const PORT = process.env.PORT || 3000;
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'anyutq1besthack';

// Database
const DB_FILE = path.join(__dirname, 'keys.json');

function initDatabase() {
    if (!fs.existsSync(DB_FILE)) {
        const initialData = {
            shared_keys: [],  // Активные общие ключи
            premium: {}       // Premium ключи (индивидуальные)
        };
        fs.writeFileSync(DB_FILE, JSON.stringify(initialData, null, 2));
    }
}

function loadDatabase() {
    return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
}

function saveDatabase(data) {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2));
}

// Генерация shared ключа
function generateSharedKey() {
    const chars = 'ABCDEFGHKLMNPQRSTUVWXYZ23456789';
    let key = 'AETH-SHARED-';
    for (let i = 0; i < 12; i++) {
        key += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return key;
}

// Генерация premium ключа
function generatePremiumKey(duration) {
    const chars = 'ABCDEFGHKLMNPQRSTUVWXYZ23456789';
    const prefix = duration === 'monthly' ? 'MONTH' : '3MNTH';
    let key = `AETH-${prefix}-`;
    for (let i = 0; i < 12; i++) {
        key += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return key;
}

// HTTP Server
const server = http.createServer((req, res) => {
    // CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Cache-Control', 'no-cache');
    
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    const url = new URL(req.url, `http://${req.headers.host}`);
    const db = loadDatabase();
    
    // ==========================================
    // VERIFY KEY
    // ==========================================
    if (url.pathname === '/verify') {
        const key = url.searchParams.get('key');
        const hwid = url.searchParams.get('hwid');
        const game = url.searchParams.get('game');
        
        if (!key || !hwid || !game) {
            res.writeHead(400);
            res.end(JSON.stringify({ error: 'Missing parameters' }));
            return;
        }
        
        // SHARED KEY - проверяем есть ли в списке активных
        if (db.shared_keys.includes(key)) {
            res.writeHead(200);
            res.end(JSON.stringify({
                valid: true,
                type: 'shared',
                message: 'Shared key valid'
            }));
            return;
        }
        
        // PREMIUM KEY
        if (db.premium[key]) {
            const keyData = db.premium[key];
            
            // Проверяем HWID
            if (keyData.hwid && keyData.hwid !== hwid) {
                res.writeHead(200);
                res.end(JSON.stringify({ valid: false, reason: 'hwid_mismatch' }));
                return;
            }
            
            // Bind HWID if first use
            if (!keyData.hwid) {
                const now = Math.floor(Date.now() / 1000);
                keyData.hwid = hwid;
                keyData.activated_at = now;
                
                if (keyData.duration === 'monthly') {
                    keyData.expires = now + (30 * 24 * 3600);
                } else if (keyData.duration === '3month') {
                    keyData.expires = now + (90 * 24 * 3600);
                }
                
                saveDatabase(db);
                console.log(`🔗 Premium key activated: ${key} → ${hwid}`);
            }
            
            // Проверяем expiry
            const now = Math.floor(Date.now() / 1000);
            if (keyData.expires && now > keyData.expires) {
                res.writeHead(200);
                res.end(JSON.stringify({ valid: false, reason: 'expired' }));
                return;
            }
            
            res.writeHead(200);
            res.end(JSON.stringify({
                valid: true,
                type: 'premium',
                expires: keyData.expires,
                duration: keyData.duration
            }));
            return;
        }
        
        // Ключ не найден
        res.writeHead(200);
        res.end(JSON.stringify({ 
            valid: false, 
            reason: 'not_found',
            message: 'Key not found. Get a new one from Discord.'
        }));
        return;
    }
    
    // ==========================================
    // CREATE SHARED KEY - создание общего ключа
    // ==========================================
    if (url.pathname === '/create-shared') {
        const password = url.searchParams.get('password');
        
        if (password !== ADMIN_PASSWORD) {
            res.writeHead(401);
            res.end(JSON.stringify({ error: 'Unauthorized' }));
            return;
        }
        
        const key = generateSharedKey();
        
        db.shared_keys.push(key);
        
        saveDatabase(db);
        
        console.log(`✅ Shared key created: ${key}`);
        
        res.writeHead(200);
        res.end(JSON.stringify({
            success: true,
            key: key,
            message: 'Update this key in Linkvertise text'
        }));
        return;
    }
    
    // ==========================================
    // DELETE SHARED KEY - удаление старого ключа
    // ==========================================
    if (url.pathname === '/delete-shared') {
        const password = url.searchParams.get('password');
        const key = url.searchParams.get('key');
        
        if (password !== ADMIN_PASSWORD) {
            res.writeHead(401);
            res.end(JSON.stringify({ error: 'Unauthorized' }));
            return;
        }
        
        if (!key) {
            res.writeHead(400);
            res.end(JSON.stringify({ error: 'Missing key parameter' }));
            return;
        }
        
        const index = db.shared_keys.indexOf(key);
        if (index > -1) {
            db.shared_keys.splice(index, 1);
            saveDatabase(db);
            
            console.log(`🗑️  Shared key deleted: ${key}`);
            
            res.writeHead(200);
            res.end(JSON.stringify({
                success: true,
                message: 'Key deleted. Users with this key will be kicked.'
            }));
        } else {
            res.writeHead(200);
            res.end(JSON.stringify({
                success: false,
                message: 'Key not found'
            }));
        }
        return;
    }
    
    // ==========================================
    // LIST SHARED KEYS - показать активные ключи
    // ==========================================
    if (url.pathname === '/list-shared') {
        const password = url.searchParams.get('password');
        
        if (password !== ADMIN_PASSWORD) {
            res.writeHead(401);
            res.end(JSON.stringify({ error: 'Unauthorized' }));
            return;
        }
        
        res.writeHead(200);
        res.end(JSON.stringify({
            shared_keys: db.shared_keys,
            count: db.shared_keys.length
        }));
        return;
    }
    
    // ==========================================
    // CREATE PREMIUM - создание premium ключа
    // ==========================================
    if (url.pathname === '/create-premium') {
        const password = url.searchParams.get('password');
        const duration = url.searchParams.get('duration');
        
        if (password !== ADMIN_PASSWORD) {
            res.writeHead(401);
            res.end(JSON.stringify({ error: 'Unauthorized' }));
            return;
        }
        
        if (duration !== 'monthly' && duration !== '3month') {
            res.writeHead(400);
            res.end(JSON.stringify({ error: 'Invalid duration' }));
            return;
        }
        
        const key = generatePremiumKey(duration);
        const now = Math.floor(Date.now() / 1000);
        
        db.premium[key] = {
            created_at: now,
            expires: null,
            duration: duration,
            hwid: null,
            activated_at: null
        };
        
        saveDatabase(db);
        
        console.log(`✅ Premium key created: ${key}`);
        
        res.writeHead(200);
        res.end(JSON.stringify({
            success: true,
            key: key,
            duration: duration
        }));
        return;
    }
    
    // ==========================================
    // STATS
    // ==========================================
    if (url.pathname === '/stats') {
        const password = url.searchParams.get('password');
        
        if (password !== ADMIN_PASSWORD) {
            res.writeHead(401);
            res.end(JSON.stringify({ error: 'Unauthorized' }));
            return;
        }
        
        const stats = {
            shared_keys: db.shared_keys.length,
            premium_total: Object.keys(db.premium).length,
            premium_active: Object.values(db.premium).filter(k => k.hwid).length
        };
        
        res.writeHead(200);
        res.end(JSON.stringify(stats));
        return;
    }
    
    // ==========================================
    // HEALTH CHECK
    // ==========================================
    if (url.pathname === '/health') {
        res.writeHead(200);
        res.end(JSON.stringify({ status: 'ok', version: '5.0.0' }));
        return;
    }
    
    // Unknown endpoint
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not found' }));
});

// Start server
initDatabase();
server.listen(PORT, () => {
    console.log(`✅ Aether Hub API Server v5.0.0 (Shared Key System)`);
    console.log(`🌐 Running on port ${PORT}`);
    console.log(`📊 Endpoints:`);
    console.log(`   GET  /verify?key=XXX&hwid=YYY&game=ZZZ`);
    console.log(`   POST /create-shared?password=XXX`);
    console.log(`   POST /delete-shared?password=XXX&key=YYY`);
    console.log(`   GET  /list-shared?password=XXX`);
    console.log(`   POST /create-premium?password=XXX&duration=monthly`);
    console.log(`   GET  /stats?password=XXX`);
    console.log(`   GET  /health`);
});
