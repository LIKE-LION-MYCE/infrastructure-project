# 🗄️ Database Connection Guide

## 📋 Connection Information
- **RDS Endpoint:** `likelion-terraform-dev-mysql.cb06282489sk.ap-northeast-2.rds.amazonaws.com:3306`  
- **Database:** `myce_database`
- **Username:** `admin`
- **Password:** `[See terraform.tfvars or ask team lead]`
- **Port:** `3306`

## 🔒 Secure Connection via SSH Tunnel

### 1. Create SSH Tunnel
```bash
# Run the tunnel script (created by Ansible)
/home/ubuntu/scripts/create_tunnel.sh

# Or manually:
ssh -L 3307:likelion-terraform-dev-mysql.cb06282489sk.ap-northeast-2.rds.amazonaws.com:3306:3306 ubuntu@43.203.98.133 -i ~/.ssh/aws/likelion-terraform-key
```

### 2. Connect to Database
```bash
mysql -h localhost -P 3307 -u admin -p myce_database
# You will be prompted for password - ask team lead for credentials
```

### 3. Close Tunnel
```bash
pkill -f 'ssh.*3307:likelion-terraform-dev-mysql.cb06282489sk.ap-northeast-2.rds.amazonaws.com:3306'
```

## 🛠️ Database Management

### Create Application User
```sql
CREATE USER 'app_user'@'%' IDENTIFIED BY 'secure_app_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON myce_database.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
```

### Connection String for Applications
```
mysql://admin:[PASSWORD]@likelion-terraform-dev-mysql.cb06282489sk.ap-northeast-2.rds.amazonaws.com:3306:3306/myce_database
# Replace [PASSWORD] with actual credentials from secure storage
```

---
*Auto-generated on Thu Jul 31 22:47:12 KST 2025*
