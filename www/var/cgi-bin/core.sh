#!/bin/bash

echo -e "Content-type: text/html\n\n"
cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>NetAttack</title>
  <meta name="viewport" content="width=device-width,height=device-height,initial-scale=1.0"/>
  <link rel="icon" type="image/png" href="/images/favicon.png">
</head>
<body>
  <i class="fa fa-bars"></i>
  </a>
  </div>
  <div class="container">
    <div class="row">
      <div class="eleven column" style="margin-top: 5%">
        <h4>Status</h4>
        <p>
          <b>OS/Branch:</b>  <code></code><br/>
          <b>Device Kernel:</b> <code>$(uname -srm)</code><br/>
          <b>NetAttack Version:</b> <code>0.1.0</code><br/>
          <b>IP Address:</b> <code>$(ip addr show eth0 | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}')</code><br/>
        </p>
        <p><b>Memory</b><br/><pre><code>$(free)</code></pre></p>
        <p><b>Disk</b><br/><pre><code>$(df -h)</code></pre></p>
        <p><b>Routes</b><br/><pre><code>$(route)</code></pre></p>
      </div>
    </div>
  </div>
</body>
</html>

EOF
