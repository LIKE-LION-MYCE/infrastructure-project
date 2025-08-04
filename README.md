# 🏗️ Infrastructure Project

Terraform을 이용한 AWS 리소스 프로비저닝과 Ansible을 이용한 서버 설정 관리를 위한 Infrastructure as Code (IaC) 솔루션.

## 🎯 빠른 시작

```bash
# 원클릭 배포
./deploy.sh

# 모니터링 스택 포함 배포
./deploy.sh --enable-monitoring

# Ansible 설정만 실행
./deploy.sh --skip-terraform
```

## 아키텍처 개요

### 인프라 구성 요소

- **VPC**: 격리된 네트워크 (10.0.0.0/16)와 public/private 서브넷
- **EC2**: Ubuntu 22.04 t3.micro 인스턴스 및 Elastic IP
- **RDS**: Private 서브넷의 MySQL 8.0 데이터베이스
- **보안**: Key 기반 SSH, fail2ban, SSL 지원 nginx

### 서버 설정

- **시스템**: Swap 메모리, SSH 터널링, 보안 강화
- **도구**: zsh, oh-my-zsh, fzf, tmux, vim, docker
- **웹 스택**: nginx, certbot, fail2ban, 로그 순환
- **모니터링**: Prometheus, Grafana, Node Exporter (선택사항)

## 배포 옵션

### 전체 배포

```bash
./deploy.sh
```

인프라를 배포하고 핵심 서비스로 서버를 설정

### 모니터링 포함 배포

```bash
./deploy.sh --enable-monitoring
```

Prometheus + Grafana 모니터링 스택을 포함

### 사용자 정의 태그

```bash
./deploy.sh --tags "system,folders,tools"
```

특정 Ansible 설정 작업을 실행

### 수동 배포

```bash
# 1. 인프라 배포
cd terraform/environments/dev
terraform apply

# 2. Terraform 출력을 Ansible에 연결
cd ../../ansible
./inventory/get_ec2_ip.sh

# 3. 서버 설정
ansible-playbook playbooks/site.yml --tags "system,folders,tools,infrastructure"
```

## 📁 디렉토리 구조

```
infrastructure-project/
├── deploy.sh                 # 🚀 원클릭 배포 스크립트
├── terraform/
│   ├── environments/
│   │   └── dev/              # 개발 환경
│   └── modules/              # 재사용 가능한 Terraform 모듈
│       ├── vpc/              # 네트워크 인프라
│       ├── ec2/              # 컴퓨팅 인스턴스
│       ├── eip/              # Elastic IP 주소
│       └── rds/              # 데이터베이스 인스턴스
└── ansible/
    ├── inventory/            # 서버 인벤토리 관리
    ├── playbooks/            # Ansible 플레이북
    └── roles/                # 설정 역할
        ├── system_config/    # 기본 시스템 설정
        ├── folder_structure/ # 애플리케이션 디렉토리
        ├── base_tools/       # CLI 도구 및 셸
        ├── programming_env/  # 개발 환경
        ├── infrastructure/   # 웹 서비스 및 보안
        └── monitoring/       # Prometheus 및 Grafana
```

## 🛠️ 사전 요구사항

### 필수 소프트웨어

- **Terraform** >= 1.0
- **Ansible** >= 2.9
- **AWS CLI** `likelion-terraform` 프로필로 설정

### AWS 설정

1. **AWS 프로필 생성**:

   ```bash
   aws configure --profile likelion-terraform
   ```

2. **EC2 Key Pair 생성** (AWS 콘솔에서):

   - 이름: `likelion-terraform-key`
   - 리전: `ap-northeast-2` (서울)
   - 다운로드 후 `~/.ssh/aws/likelion-terraform-key`에 저장
   - 권한 설정: `chmod 600 ~/.ssh/aws/likelion-terraform-key`

3. **필요한 AWS 권한**:
   - EC2 (인스턴스, 보안 그룹, 키 페어)
   - VPC (네트워크, 서브넷, 게이트웨이)
   - RDS (데이터베이스, 서브넷 그룹)
   - Route53 (사용자 정의 도메인 사용 시)

## 🌐 네트워크 및 보안

### 포트 설정

- **22** - SSH 접근 (키 기반 인증)
- **80** - HTTP (HTTPS로 리다이렉트)
- **443** - HTTPS (certbot을 통한 SSL 인증서)
- **3000** - Grafana 대시보드 (선택사항)
- **9090** - Prometheus 메트릭 (선택사항)

### 보안 기능

- **fail2ban**: SSH 무차별 대입 공격 방지
- **키 인증**: 비밀번호 없는 SSH 접근
- **Private RDS**: Private 서브넷에 격리된 데이터베이스
- **SSH 터널링**: 팀을 위한 안전한 데이터베이스 접근
- **보안 그룹**: 네트워크 수준 접근 제어

## 📊 모니터링 스택 (선택사항)

`--enable-monitoring` 플래그로 활성화:

### 서비스

- **Prometheus**: `http://your-server:9090`
- **Grafana**: `http://your-server:3000` (admin/grafana123)
- **Node Exporter**: 포트 9100의 시스템 메트릭

### 디렉토리 레이아웃

```
/home/ubuntu/
├── config/
│   ├── prometheus/          # Prometheus 설정
│   └── grafana/            # Grafana 설정
├── apps/monitoring/
│   └── grafana/dashboards/ # 사용자 정의 대시보드
├── logs/                   # 애플리케이션 로그
└── /opt/monitoring/        # 데이터 저장소
```

## 🗄️ 데이터베이스 관리

### 🚀 빠른 데이터베이스 설정

```bash
# 한 번에 터널 생성 + 사용자 설정
./setup_database.sh

# 커스텀 비밀번호로 설정
MYCE_PASSWORD=secure123 JOBDAM_PASSWORD=secure456 ./setup_database.sh

# 터널만 관리
./setup_database.sh tunnel-start
./setup_database.sh tunnel-stop
./setup_database.sh tunnel-status
```

### 연결 정보

- **호스트**: RDS 엔드포인트 (private 서브넷)
- **데이터베이스**: `myce_database`
- **관리자**: `admin` / `myceforever`
- **터널 포트**: `3307` (로컬)

### 자동 생성되는 사용자

**MYCE 팀:**
- `myce_choi`, `myce_gu`, `myce_g1`, `myce_lee`
- `myce_kim`, `myce_in`, `myce_hwang`

**Jobdam 팀:**
- `jobdam_juan`, `jobdam_prod`

모든 사용자는 `myce_database.*`에 대한 전체 권한을 가집니다.

### SSH 터널을 통한 안전한 접근

**자동화된 방법 (권장):**
```bash
./setup_database.sh tunnel-start  # 터널 시작
mysql -h localhost -P 3307 -u myce_choi -p myce_database
```

**수동 터널:**
```bash
# 1. SSH 키 복사 (최초 1회)
scp -i ~/.ssh/aws/likelion-terraform-key ubuntu@43.203.98.133:/home/dbtunnel/.ssh/db_tunnel_key ./dbtunnel_private_key
chmod 600 ./dbtunnel_private_key

# 2. 터널 생성
ssh -N -L 3307:likelion-terraform-dev-mysql.cb06282489sk.ap-northeast-2.rds.amazonaws.com:3306 dbtunnel@43.203.98.133 -i dbtunnel_private_key

# 3. 데이터베이스 연결
mysql -h localhost -P 3307 -u admin -p myce_database
```

### 팀 접근 관리

데이터베이스 전용 SSH 터널링:

- **터널 사용자**: `dbtunnel`
- **키 위치**: `/home/dbtunnel/.ssh/db_tunnel_key` (EC2에서)
- **제한사항**: 포트 포워딩만 가능, 셸 접근 불가
- **로컬 키**: `./dbtunnel_private_key` (로컬 복사본)

### 데이터베이스 스크립트 명령어

```bash
# 전체 설정 (터널 + 사용자 생성)
./setup_database.sh

# 커스텀 비밀번호로 설정
MYCE_PASSWORD=YourPassword123 ./setup_database.sh

# 터널 관리만
./setup_database.sh tunnel-start    # 터널 시작
./setup_database.sh tunnel-stop     # 터널 중지
./setup_database.sh tunnel-status   # 터널 상태 확인

# 도움말
./setup_database.sh help
```

### 🔧 Manual Database Setup

Ansible playbook 직접 실행:

```bash
cd ansible
ansible-playbook -i inventory/hosts playbooks/database.yml
```

## 🔧 설정 파일

### Terraform 변수

`terraform/environments/dev/terraform.tfvars` 편집:

```hcl
db_password = "your-secure-password"
```

### Ansible 변수

배포 후 `ansible/group_vars/all.yml`에 자동 생성.

## 📚 생성된 문서

배포 후 다음에서 자세한 가이드 찾기:

- `ansible/database-connection-guide.md` - 데이터베이스 접근 지침
- `/home/ubuntu/logs/`의 서버 로그
- `/home/ubuntu/config/`의 설정 파일

## 🎛️ 서버 디렉토리 구조

자동으로 생성되는 정리된 애플리케이션 레이아웃:

```
/home/ubuntu/
├── apps/
│   ├── backend/            # 백엔드 서비스 및 Docker 설정
│   ├── frontend/           # 정적 프론트엔드 빌드
│   └── monitoring/         # 모니터링 도구 및 대시보드
├── logs/                   # 중앙화된 애플리케이션 로그
├── scripts/                # 배포 및 유틸리티 스크립트
├── docker/                 # Docker Compose 파일
└── config/                 # 설정 파일 및 템플릿
```

## 🚨 문제 해결

### 일반적인 문제

**권한 오류로 Terraform 실패**:

```bash
aws sts get-caller-identity --profile likelion-terraform
```

**Ansible 연결 불가**:

```bash
ansible all -m ping  # 연결 테스트
ssh -i ~/.ssh/aws/likelion-terraform-key ubuntu@server-ip  # 수동 테스트
```

**서비스 시작 안됨**:

```bash
# 서비스 상태 확인
sudo systemctl status nginx
sudo systemctl status prometheus
sudo systemctl status grafana-server
```

### 유용한 명령어

```bash
# Terraform 상태 확인
cd terraform/environments/dev && terraform show

# Ansible 연결 테스트
cd ansible && ansible all -m ping

# 서버 설정 확인
ansible all -a "df -h"  # 디스크 사용량
ansible all -a "free -m"  # 메모리 사용량
ansible all -a "systemctl list-units --type=service --state=running"  # 서비스 목록
```

## 🔄 업데이트 및 유지보수

### 인프라 업데이트

```bash
cd terraform/environments/dev
terraform plan    # 변경사항 검토
terraform apply   # 업데이트 적용
```

### 서버 설정 업데이트

```bash
cd ansible
ansible-playbook playbooks/site.yml --tags "specific-tag"
```

### 기존 설정에 모니터링 추가

```bash
ansible-playbook playbooks/site.yml --tags "monitoring" -e "enable_monitoring=true"
```

## 🤝 기여하기

1. 개발 환경에서 먼저 변경사항 테스트
2. 새로운 기능에 대한 문서 업데이트
3. 보안 모범 사례 준수
4. 의미 있는 커밋 메시지 사용

## 🌐 프론트엔드 CDN 인프라

이 프로젝트에는 S3와 CloudFront를 사용한 정적 웹사이트 호스팅 및 미디어 배포를 위한 별도의 프론트엔드 인프라가 포함되어 있습니다.

### 추가된 구성 요소:

**새로운 Terraform 모듈:**
- `terraform/modules/s3/` - 프론트엔드 자산 및 미디어 저장을 위한 S3 버킷
- `terraform/modules/cloudfront/` - CloudFront CDN 배포판

**새로운 환경:**
- `terraform/environments/frontend/` - 완전한 S3 + CloudFront 구성

### 주요 기능:

- **프론트엔드 버킷**: 정적 웹사이트 호스팅용 퍼블릭 S3 버킷 (React/Vue/Angular 앱)
- **미디어 버킷**: 서명된 URL로 안전한 미디어 저장을 위한 프라이빗 S3 버킷
- **CloudFront CDN**: 캐싱 최적화를 통한 글로벌 콘텐츠 배포
- **보안**: 안전한 S3 접근을 위한 Origin Access Control (OAC)
- **SPA 지원**: 단일 페이지 애플리케이션을 위한 사용자 정의 오류 처리

### 배포 방법:

```bash
# 프론트엔드 환경으로 이동
cd terraform/environments/frontend

# 변수 파일 복사 및 구성
cp terraform.tfvars.example terraform.tfvars

# 초기화 및 배포
terraform init
terraform plan
terraform apply
```

### 설정:

`terraform/environments/frontend/terraform.tfvars` 편집:
```hcl
aws_region = "ap-northeast-2"
aws_profile = "likelion-terraform-current"
project_prefix = "myce"
environment = "frontend"
```

### 배포 결과:

배포 완료 후 다음을 얻을 수 있습니다:
- **프론트엔드 URL**: `https://xyz.cloudfront.net` - 웹 애플리케이션 호스팅용
- **미디어 URL**: `https://abc.cloudfront.net` - 미디어 파일 서빙용
- **S3 버킷 이름**: AWS CLI 또는 SDK를 통한 콘텐츠 업로드용

### 사용 예시:

**프론트엔드 파일 업로드:**
```bash
aws s3 sync ./build/ s3://myce-frontend-bucket --profile likelion-terraform-current
```

**미디어 파일 업로드:**
```bash
aws s3 cp ./image.jpg s3://myce-media-bucket/images/ --profile likelion-terraform-current
```

**CloudFront 캐시 무효화:**
```bash
aws cloudfront create-invalidation --distribution-id DISTRIBUTION_ID --paths "/*" --profile likelion-terraform-current
```

## 📞 지원

문제 및 질문은:

1. 문제 해결 섹션 확인
2. 생성된 문서 검토
3. `/home/ubuntu/logs/`의 서비스 로그 확인
4. AWS 콘솔에서 리소스 상태 확인

