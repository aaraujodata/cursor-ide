# Cloudflare Tunnel Configuration

This document describes the Cloudflare Tunnel setup for exposing the Platziflix backend API to the public internet.

## Overview

The Platziflix backend API is exposed via Cloudflare Tunnel, which provides secure access without opening firewall ports or exposing your origin server's IP address directly to the internet.

**Public URL**: `platziflix-api.alexisaraujo.com`
- HTTP: ✅ Working
- HTTPS: ✅ Working

## Tunnel Details

- **Tunnel Name**: platziflix-backend
- **Tunnel ID**: 0ec2b091-4ce8-4a81-bfab-0171bde82135
- **Domain**: alexisaraujo.com (managed by Cloudflare, registered with Namecheap)
- **Subdomain**: platziflix-api.alexisaraujo.com
- **Origin Service**: http://localhost:8000 (FastAPI backend)
- **Created**: November 3, 2025

## Architecture

```
Internet → Cloudflare Edge → Cloudflare Tunnel (cloudflared) → localhost:8000 (FastAPI)
           (TLS Termination)  (Encrypted Connection)            (HTTP)
```

### How It Works

1. **Client Request**: User makes request to `platziflix-api.alexisaraujo.com`
2. **DNS Resolution**: Cloudflare DNS resolves to Cloudflare's edge network
3. **Edge Processing**: Cloudflare edge handles TLS termination and security
4. **Tunnel**: Encrypted connection from edge to your local `cloudflared` daemon
5. **Origin**: `cloudflared` forwards request to `localhost:8000` (your FastAPI app)
6. **Response**: Flows back through the same path

## Setup Steps (Already Completed)

### 1. Authentication
```bash
cloudflared tunnel login
```
- Opens browser for Cloudflare authentication
- Saves certificate to `~/.cloudflared/cert.pem`

### 2. Tunnel Creation
```bash
cloudflared tunnel create platziflix-backend
```
- Creates tunnel with unique ID
- Generates credentials file: `~/.cloudflared/0ec2b091-4ce8-4a81-bfab-0171bde82135.json`

### 3. DNS Route
```bash
cloudflared tunnel route dns platziflix-backend platziflix-api.alexisaraujo.com
```
- Creates CNAME record pointing to the tunnel
- DNS: `platziflix-api.alexisaraujo.com` → `<tunnel-id>.cfargotunnel.com`

### 4. Configuration File
Location: `~/.cloudflared/config.yml`

```yaml
tunnel: 0ec2b091-4ce8-4a81-bfab-0171bde82135
credentials-file: /Users/alexis.araujo/.cloudflared/0ec2b091-4ce8-4a81-bfab-0171bde82135.json

# Tunnel-level options
originRequest:
  noTLSVerify: true
  connectTimeout: 30s
  tcpKeepAlive: 30s

ingress:
  - hostname: platziflix-api.alexisaraujo.com
    service: http://localhost:8000
    originRequest:
      noTLSVerify: true
  - service: http_status:404
```

**Configuration Explained**:
- `tunnel`: Unique tunnel identifier
- `credentials-file`: Path to tunnel credentials (keep secure!)
- `originRequest.noTLSVerify`: Disables TLS verification for localhost (HTTP origin)
- `originRequest.connectTimeout`: 30s timeout for origin connections
- `originRequest.tcpKeepAlive`: Keep TCP connections alive
- `ingress`: Routing rules for incoming requests
  - First rule: Route `platziflix-api.alexisaraujo.com` to `http://localhost:8000`
  - Catch-all: Return 404 for unmatched requests

### 5. Start the Tunnel
```bash
cloudflared tunnel run platziflix-backend
```

## Managing the Tunnel

### Check Tunnel Status
```bash
# Get tunnel information
cloudflared tunnel info platziflix-backend

# List all tunnels
cloudflared tunnel list
```

### Start/Stop Tunnel

**Start** (foreground):
```bash
cloudflared tunnel run platziflix-backend
```

**Start** (background):
```bash
cloudflared tunnel run platziflix-backend &
```

**Stop**:
```bash
# Find the process
ps aux | grep cloudflared

# Kill the process
kill <PID>
```

### Run as a System Service (Recommended for Production)

**Install service**:
```bash
sudo cloudflared service install
```

**Start service**:
```bash
sudo launchctl start com.cloudflare.cloudflared
```

**Stop service**:
```bash
sudo launchctl stop com.cloudflare.cloudflared
```

**Check service status**:
```bash
sudo launchctl list | grep cloudflared
```

### View Logs

**If running in foreground**: Logs appear in terminal

**If running as service**:
```bash
# macOS
tail -f /usr/local/var/log/cloudflared.log

# Or check system logs
log show --predicate 'process == "cloudflared"' --last 1h
```

### Metrics

Cloudflared exposes metrics at:
```
http://127.0.0.1:20241/metrics
```

View metrics:
```bash
curl http://127.0.0.1:20241/metrics
```

## SSL/TLS Configuration

### Current Status
- **HTTP**: ✅ Working (`http://platziflix-api.alexisaraujo.com`)
- **HTTPS**: ✅ Working (`https://platziflix-api.alexisaraujo.com`)

### Configuration Applied
The SSL/TLS has been successfully configured in the Cloudflare Dashboard with the following settings:
- **Encryption Mode**: Full (or Full Strict)
- **Universal SSL**: Enabled and Active
- **Certificate**: Cloudflare Universal SSL Certificate
- **Coverage**: `*.alexisaraujo.com` and `alexisaraujo.com`

### ✅ Issue Resolved
SSL/TLS is now properly configured and HTTPS is working.

### Setup Instructions (For Reference)

**Step 1: Log in to Cloudflare Dashboard**
1. Go to https://dash.cloudflare.com/
2. Select the domain: `alexisaraujo.com`

**Step 2: Configure SSL/TLS Settings**
1. Navigate to **SSL/TLS** in the left menu
2. Click on **Overview**
3. Set the SSL/TLS encryption mode:
   - **Recommended**: `Full` or `Full (strict)`
   - For Cloudflare Tunnels: Use `Full` mode
   - ⚠️ Do NOT use `Off` or `Flexible` mode

**SSL/TLS Modes Explained**:
- **Off**: No encryption (not recommended)
- **Flexible**: Cloudflare ↔ Visitor (HTTPS), Cloudflare ↔ Origin (HTTP) - **Works but less secure**
- **Full**: Encrypts both connections, allows self-signed certs on origin
- **Full (strict)**: Encrypts both, requires valid cert on origin (most secure)

**Step 3: Enable Universal SSL**
1. Go to **SSL/TLS** → **Edge Certificates**
2. Verify **Universal SSL** is enabled
3. Status should show: `Active Certificate`
4. If not, enable it and wait 15-30 minutes for provisioning

**Step 4: Check Certificate Status**
1. Under **Edge Certificates**, verify:
   - **Universal SSL Status**: Active
   - **Certificate**: Should show Cloudflare certificate
   - **Hostnames covered**: Should include `*.alexisaraujo.com`

**Step 5: Enable Always Use HTTPS (Optional)**
1. Go to **SSL/TLS** → **Edge Certificates**
2. Scroll to **Always Use HTTPS**
3. Toggle **On** to redirect HTTP → HTTPS automatically

**Step 6: Verify** ✅
```bash
curl https://platziflix-api.alexisaraujo.com/health
```

Returns:
```json
{"status":"ok","service":"Platziflix","version":"0.1.0","database":true,"courses_count":3}
```

**Status**: HTTPS is now fully operational!

### Certificate Details

The domain is protected by:
- **Certificate Authority**: Cloudflare Universal SSL
- **Coverage**: Wildcard certificate (`*.alexisaraujo.com`)
- **Protocol**: TLS 1.3
- **Cipher Suites**: Modern and secure (managed by Cloudflare)

**Note**: In corporate environments, traffic may be inspected by security tools (e.g., Zscaler), which is normal and expected.

## Testing the API

### Health Check
```bash
# HTTP
curl http://platziflix-api.alexisaraujo.com/health

# HTTPS (recommended)
curl https://platziflix-api.alexisaraujo.com/health
```

Both return:
```json
{"status":"ok","service":"Platziflix","version":"0.1.0","database":true,"courses_count":3}
```

### List All Courses
```bash
curl https://platziflix-api.alexisaraujo.com/courses
```

### Get Course by Slug
```bash
curl https://platziflix-api.alexisaraujo.com/courses/curso-de-react
```

### Root Endpoint
```bash
curl https://platziflix-api.alexisaraujo.com/
```

**Response**:
```json
{"message":"Bienvenido a Platziflix API"}
```

## Security Considerations

### Credentials Files
**Keep these files secure**:
- `~/.cloudflared/cert.pem` - Origin certificate
- `~/.cloudflared/0ec2b091-4ce8-4a81-bfab-0171bde82135.json` - Tunnel credentials

**Permissions**:
```bash
chmod 600 ~/.cloudflared/*.json
chmod 600 ~/.cloudflared/cert.pem
```

**Backup**:
```bash
# Backup credentials (store securely!)
cp -r ~/.cloudflared ~/cloudflared-backup
```

### Revoking Access
To revoke tunnel access:
```bash
cloudflared tunnel delete platziflix-backend
```
This will:
- Delete the tunnel
- Invalidate credentials
- Remove DNS route

### Firewall
With Cloudflare Tunnel, you don't need to open firewall ports. The tunnel creates an outbound connection only.

## Troubleshooting

### Tunnel Won't Start
```bash
# Check if port 8000 is accessible
curl http://localhost:8000/health

# Check if backend is running
docker-compose ps

# Verify configuration
cat ~/.cloudflared/config.yml
```

### DNS Not Resolving
```bash
# Check DNS
dig platziflix-api.alexisaraujo.com

# Should show Cloudflare IPs (104.x.x.x or 172.x.x.x)
```

### Connection Refused
```bash
# Ensure backend is running
make start

# Wait for backend to initialize
sleep 10

# Verify backend responds locally
curl http://localhost:8000/health
```

### Certificate Errors
```bash
# Check what's being presented
echo | openssl s_client -connect platziflix-api.alexisaraujo.com:443 -servername platziflix-api.alexisaraujo.com

# If "no peer certificate available", check Cloudflare dashboard SSL/TLS settings
```

### Tunnel Disconnects
Check logs for errors:
```bash
# If running in foreground, check terminal output
# Look for connection errors or authentication failures

# Common issues:
# - Network connectivity
# - Invalid credentials
# - Tunnel deleted from Cloudflare dashboard
```

## Performance Monitoring

### Connection Status
```bash
cloudflared tunnel info platziflix-backend
```

Shows:
- Connector ID
- Number of connections
- Edge locations (e.g., lax01, lax07)
- Origin IP

### Metrics
```bash
# Prometheus-compatible metrics
curl http://127.0.0.1:20241/metrics | grep cloudflared
```

Key metrics:
- `cloudflared_tunnel_total_requests`: Total requests
- `cloudflared_tunnel_request_errors`: Error count
- `cloudflared_tunnel_concurrent_requests_per_tunnel`: Active requests

## Cloudflare Dashboard Configuration

### Access Control (Optional)
You can add access policies in Cloudflare dashboard:
1. Go to **Access** → **Applications**
2. Add application for `platziflix-api.alexisaraujo.com`
3. Configure authentication (email, SSO, etc.)

### Rate Limiting (Optional)
Protect your API from abuse:
1. Go to **Security** → **WAF** → **Rate limiting rules**
2. Create rule for `platziflix-api.alexisaraujo.com`
3. Set limits (e.g., 100 requests/minute per IP)

### Analytics
View traffic analytics:
1. Go to **Analytics & Logs** → **Traffic**
2. Filter by hostname: `platziflix-api.alexisaraujo.com`
3. View requests, bandwidth, threats blocked

## Integration with Backend

### Environment Variables
The backend doesn't need to know about the tunnel. It just runs on `localhost:8000` as usual.

### CORS Configuration
If you need to allow frontend access, add CORS in `app/main.py`:
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-frontend.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### X-Forwarded Headers
Cloudflare adds headers that you can use:
- `X-Forwarded-For`: Client's real IP
- `X-Forwarded-Proto`: Original protocol (http/https)
- `CF-Connecting-IP`: Cloudflare's header for client IP

Access in FastAPI:
```python
from fastapi import Request

@app.get("/")
def root(request: Request):
    client_ip = request.headers.get("CF-Connecting-IP")
    return {"client_ip": client_ip}
```

## Migration & Cleanup

### Moving to Another Machine
1. Copy tunnel credentials:
   ```bash
   scp -r ~/.cloudflared user@new-machine:~/
   ```
2. Install cloudflared on new machine
3. Run the tunnel with same config

### Deleting the Tunnel
```bash
# Stop the tunnel first
kill <cloudflared-pid>

# Delete the tunnel
cloudflared tunnel delete platziflix-backend

# Remove DNS route (or do it in dashboard)
# Remove local files
rm -rf ~/.cloudflared/
```

## Additional Resources

- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [Cloudflare Dashboard](https://dash.cloudflare.com/)
- [Tunnel GitHub](https://github.com/cloudflare/cloudflared)

## Summary

✅ **What's Working**:
- Tunnel created and running
- DNS configured (CNAME to tunnel)
- HTTP access working perfectly
- HTTPS access working perfectly
- SSL/TLS properly configured
- Backend accessible at:
  - `http://platziflix-api.alexisaraujo.com`
  - `https://platziflix-api.alexisaraujo.com` ✅

🎯 **Optional Next Steps**:
- Set up rate limiting in Cloudflare Dashboard
- Configure access control/authentication
- Run tunnel as system service for persistence
- Enable "Always Use HTTPS" redirect

---

**Created**: November 3, 2025
**Last Updated**: November 3, 2025
**Tunnel ID**: 0ec2b091-4ce8-4a81-bfab-0171bde82135
