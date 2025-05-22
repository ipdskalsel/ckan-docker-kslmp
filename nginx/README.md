# Nginx Docker Setup with Persistent Self-Signed SSL Certificate
Made by: Sansadewa, 22 May 2025.

This guide shows you how to set up your Nginx Docker container with a **persistent self-signed SSL certificate**. This is super important when you're using an external reverse proxy like OpenLiteSpeed (via CyberPanel) that needs to connect to your Nginx Docker container securely over HTTPS. It means your certificate stays the same, even if your Nginx Docker container restarts or gets rebuilt.

We'll **generate the certificate and key once on your host machine** within your `nginx/setup/certs/` folder, and then **bundle them directly into the Nginx Docker image** when it's built.

---

## Prerequisites

Before we start, make sure you have:

* A working **Docker and Docker Compose** environment.
* Your project's root directory is `~/ckan-docker/` (this is where your `docker-compose.yml` file lives).
* Your Nginx Dockerfile is located at `~/ckan-docker/nginx/Dockerfile`.
* Your Nginx configuration files, including `default.conf` (which holds your SSL settings), are in `~/ckan-docker/nginx/setup/` on your host.
* CyberPanel with OpenLiteSpeed acting as a reverse proxy.

---

## Step 1: Generate Persistent SSL Certificate and Key on Your Host

First, you'll create the certificate and key files directly on your computer. These files will be copied into the Nginx Docker image later.

1.  **Go to your project root** (`~/ckan-docker/`) in your terminal:

    ```bash
    cd ~/ckan-docker/
    ```

2.  **Make sure the `nginx/setup/` directory exists**:

    ```bash
    mkdir -p nginx/setup/
    ```

3.  **Generate the Certificate and Key**: Run this `openssl` command.
    * **Crucially**: The **Common Name (`CN`)** in the `-subj` part **must match the hostname or IP address** that your OpenLiteSpeed reverse proxy will use to connect to your Nginx Docker container.
        * If OLS connects using `localhost` or `127.0.0.1`, use `CN=localhost`.
        * If OLS connects using your Docker host's specific IP address (e.g., `192.168.1.100`), use that IP for the `CN`.
        * Make sure you are in the `nginx` folder.

    ```bash
    openssl req \
        -subj '/C=ID/ST=South Kalimantan/L=Banjarbaru/O=MyOrg/CN=localhost' \
        -x509 -newkey rsa:4096 -nodes \
        -keyout ./setup/ckan-local.key \
        -out ./setup/ckan-local.crt \
        -days 3650 # This certificate will be valid for 10 years for stability
    ```
    You'll now find `ckan-local.key` (your private key) and `ckan-local.crt` (your certificate) inside the `~/ckan-docker/nginx/setup` directory.

---

## Step 2: Update Your Nginx Dockerfile

Now, you'll modify your Nginx Dockerfile. We need to remove any old certificate generation code and add lines to **copy** your newly created persistent certificates and configuration files into the image.

1.  **Open `~/ckan-docker/nginx/Dockerfile`**.

2.  **Remove or comment out** any lines that involve `openssl req` or similar commands that generate SSL certificates and keys during the build or when the container starts. (If you had an `ENTRYPOINT` line for `openssl`, remove it).

3.  **Add the following `COPY` lines** to your `Dockerfile`. Place them after your `FROM` instruction and any initial package installations, but before the `CMD` instruction.

    ```
    #dockerfile
    
    # Copy the generated certificates and key from your host's ./nginx/setup/ folder
    # The destination paths MUST match where Nginx expects them inside the container
    COPY setup/ckan-local.key /etc/nginx/certs/ckan-local.key
    COPY setup/ckan-local.crt /etc/nginx/certs/ckan-local.crt

    # Ensure Nginx starts in the foreground (this is essential for Docker)
    CMD ["nginx", "-g", "daemon off;"]

    ```

---

## Step 3: Verify Nginx `default.conf` Content (on your host)

Your `default.conf` file, located at `~/ckan-docker/nginx/setup/conf.d/default.conf`, already has the correct `ssl_certificate` and `ssl_certificate_key` directives pointing to `/etc/nginx/certs/ckan-local.crt` and `/etc/nginx/certs/ckan-local.key`. **No changes are needed for this file!**

It should look something like this:

```nginx
# --- Inside ~/ckan-docker/nginx/setup/conf.d/default.conf ---

server {
    # ... other listen directives if any ...
    listen        443 ssl;
    listen    [::]:443 ssl;
    server_name   localhost; # Or the domain/IP your Nginx will be accessed by

    ssl_certificate /etc/nginx/certs/ckan-local.crt;
    ssl_certificate_key /etc/nginx/certs/ckan-local.key;

    # ... rest of your Nginx configuration, including proxy_pass ...
}
# --- End of Nginx config file ---
```
You are absolutely right! My apologies for that oversight. I'll make sure the closing triple backticks are in place for the default.conf content.

Here is the corrected and final README.md in its entirety, ready for you to copy:
Markdown

# Nginx Docker Setup with Persistent Self-Signed SSL Certificate

This guide shows you how to set up your Nginx Docker container with a **persistent self-signed SSL certificate**. This is super important when you're using an external reverse proxy like OpenLiteSpeed (via CyberPanel) that needs to connect to your Nginx Docker container securely over HTTPS. It means your certificate stays the same, even if your Nginx Docker container restarts or gets rebuilt.

We'll **generate the certificate and key once on your host machine** within your `nginx/setup/certs/` folder, and then **bundle them directly into the Nginx Docker image** when it's built.

---

## Prerequisites

Before we start, make sure you have:

* A working **Docker and Docker Compose** environment.
* Your project's root directory is `~/ckan-docker/` (this is where your `docker-compose.yml` file lives).
* Your Nginx Dockerfile is located at `~/ckan-docker/nginx/Dockerfile`.
* Your Nginx configuration files, including `default.conf` (which holds your SSL settings), are in `~/ckan-docker/nginx/setup/` on your host.
* CyberPanel with OpenLiteSpeed acting as a reverse proxy.

---

## Step 1: Generate Persistent SSL Certificate and Key on Your Host

First, you'll create the certificate and key files directly on your computer. These files will be copied into the Nginx Docker image later.

1.  **Go to your project root** (`~/ckan-docker/`) in your terminal:

    ```bash
    cd ~/ckan-docker/
    ```

2.  **Make sure the `nginx/setup/certs` directory exists**:

    ```bash
    mkdir -p nginx/setup/certs
    ```

3.  **Generate the Certificate and Key**: Run this `openssl` command.
    * **Crucially**: The **Common Name (`CN`)** in the `-subj` part **must match the hostname or IP address** that your OpenLiteSpeed reverse proxy will use to connect to your Nginx Docker container.
        * If OLS connects using `localhost` or `127.0.0.1`, use `CN=localhost`.
        * If OLS connects using your Docker host's specific IP address (e.g., `192.168.1.100`), use that IP for the `CN`.

    ```bash
    openssl req \
        -subj '/C=ID/ST=South Kalimantan/L=Banjarbaru/O=MyOrg/CN=localhost' \
        -x509 -newkey rsa:4096 -nodes \
        -keyout ./nginx/setup/certs/ckan-local.key \
        -out ./nginx/setup/certs/ckan-local.crt \
        -days 3650 # This certificate will be valid for 10 years for stability
    ```
    You'll now find `ckan-local.key` (your private key) and `ckan-local.crt` (your certificate) inside the `~/ckan-docker/nginx/setup/certs` directory.

---

## Step 2: Update Your Nginx Dockerfile

Now, you'll modify your Nginx Dockerfile. We need to remove any old certificate generation code and add lines to **copy** your newly created persistent certificates and configuration files into the image.

1.  **Open `~/ckan-docker/nginx/Dockerfile`**.

2.  **Remove or comment out** any lines that involve `openssl req` or similar commands that generate SSL certificates and keys during the build or when the container starts. (If you had an `ENTRYPOINT` line for `openssl`, remove it).

3.  **Add the following `COPY` lines** to your `Dockerfile`. Place them after your `FROM` instruction and any initial package installations, but before the `CMD` instruction.

    ```dockerfile
    # --- Inside ~/ckan-docker/nginx/Dockerfile ---

    # Your base Nginx image (e.g., from an official Nginx image or CKAN's base)
    FROM nginx:latest # Example: FROM ckan/ckan-base-nginx:latest

    # Add these COPY lines:
    # Copy your Nginx configuration files from your host's ./nginx/setup/ folder
    # 'setup/' is relative to the Dockerfile's context (which is 'nginx/')
    COPY setup/nginx.conf /etc/nginx/nginx.conf  # If you have a main nginx.conf
    COPY setup/conf.d/ /etc/nginx/conf.d/       # This copies your default.conf and others

    # Copy the generated certificates and key from your host's ./nginx/setup/certs/ folder
    # The destination paths MUST match where Nginx expects them inside the container
    COPY setup/certs/ckan-local.key /etc/nginx/certs/ckan-local.key
    COPY setup/certs/ckan-local.crt /etc/nginx/certs/ckan-local.crt

    # Ensure Nginx starts in the foreground (this is essential for Docker)
    CMD ["nginx", "-g", "daemon off;"]

    # --- End of Dockerfile ---
    ```

---

## Step 3: Verify Nginx `default.conf` Content (on your host)

Your `default.conf` file, located at `~/ckan-docker/nginx/setup/conf.d/default.conf`, already has the correct `ssl_certificate` and `ssl_certificate_key` directives pointing to `/etc/nginx/certs/ckan-local.crt` and `/etc/nginx/certs/ckan-local.key`. **No changes are needed for this file!**

It should look something like this:

```nginx
# --- Inside ~/ckan-docker/nginx/setup/conf.d/default.conf ---

server {
    # ... other listen directives if any ...
    listen        443 ssl;
    listen    [::]:443 ssl;
    server_name   localhost; # Or the domain/IP your Nginx will be accessed by

    ssl_certificate /etc/nginx/certs/ckan-local.crt;
    ssl_certificate_key /etc/nginx/certs/ckan-local.key;

    # ... rest of your Nginx configuration, including proxy_pass ...
}
# --- End of Nginx config file ---
```
## Step 4: Deploy the Updated Docker Compose Stack

Now it's time to apply these changes to your Docker environment. Your docker-compose.yml file itself doesn't need to be edited for this setup, as the changes are within the Dockerfile and the file system layout.

Go to your project root (where docker-compose.yml is):


    cd ~/ckan-docker/

Stop and rebuild your Docker services:
```

    docker-compose down       # Stops and removes existing containers and networks
    docker-compose up --build -d # IMPORTANT: Rebuilds the Nginx image with the new Dockerfile, then starts containers in detached mode
```
The --build flag is crucial because you've modified the nginx/Dockerfile.

## Step 5: Configure CyberPanel/OpenLiteSpeed to Trust the Certificate

This is the final, essential step to get your OpenLiteSpeed reverse proxy to securely connect to your Nginx Docker container over HTTPS.

Copy the ckan-local.crt file (from ~/ckan-docker/nginx/setup/certs/ on your Docker host) to a location on your CyberPanel server that OpenLiteSpeed can access. A common spot for custom CA certificates is /etc/ssl/certs/.
    Bash

### On your CyberPanel server:
    sudo cp ~/ckan-docker/nginx/setup/certs/ckan-local.crt /etc/ssl/certs/
### (Optional, but good practice for system-wide trust)
    sudo update-ca-certificates

Note: If your project root on the CyberPanel server isn't ~/ckan-docker/, adjust the source path accordingly (e.g., /var/www/yourproject/nginx/setup/certs/ckan-local.crt).

Tell CyberPanel/OpenLiteSpeed to Trust the Certificate:

1. Log into your CyberPanel dashboard.
2. Go to Websites > List Websites and click "Manage" for the website that's performing the reverse proxy.
3. Look for settings related to "Reverse Proxy" or "External App" for your site.
When configuring the backend entry for your Nginx Docker container (e.g., https://127.0.0.1:8443 or https://docker_host_ip:8443), there should be an option to upload or specify a "CA Certificate File" for the backend connection.
4. This is where you will point it to the ckan-local.crt file you just copied to the CyberPanel server. This tells OpenLiteSpeed to explicitly trust that specific certificate when making an outgoing HTTPS connection to your Nginx container.

5. Restart OpenLiteSpeed: After making these changes in CyberPanel/OLS, restart the OpenLiteSpeed service for them to take effect.

   ``` sudo systemctl restart lsws ```

You can also restart it through the CyberPanel dashboard.
