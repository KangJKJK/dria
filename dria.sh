#!/bin/bash

NODENAME="dria"

# 컬러 정의
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[0;32m'
export NC='\033[0m'  # No Color

# 안내 메시지
echo -e "${YELLOW}Dria 노드 설치를 시작합니다.${NC}"
read -p "스크린 생성 후 스크립트를 실행하셔야합니다. (엔터): "

# 패키지 업데이트 및 필요한 패키지 설치
echo -e "${YELLOW}패키지 업데이트 및 필요한 패키지 설치 중...${NC}"
sudo apt update && sudo apt install -y ca-certificates curl gnupg ufw && sudo apt install expect

# 도커 설치
dockerSetup(){
    if ! command -v docker &> /dev/null; then
        echo "Docker 설치 중..."

        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
            sudo apt-get remove -y $pkg
        done

        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        
        sudo apt update -y && sudo apt install -y docker-ce
        sudo systemctl start docker
        sudo systemctl enable docker

        echo "Docker Compose 설치 중..."

        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        echo "Docker가 성공적으로 설치되었습니다."

    else
        echo "Docker가 이미 설치되어 있습니다."

    fi
}

# 초기 설정
setup() {
    cd ~
    if [ -d "node" ]; then
        echo -e "${GREEN}/root/node 디렉토리가 이미 존재합니다. 삭제 중...${NC}"
        rm -rf node  # 기존 node 디렉토리 삭제
        echo -e "${YELLOW}/root/node 디렉토리를 삭제했습니다.${NC}"
    fi

    mkdir node
    echo -e "${YELLOW}/root/node 디렉토리를 생성했습니다.${NC}"
    cd node

    if [ -d "$NODENAME" ]; then
        echo -e "${GREEN}/root/node/$NODENAME 디렉토리가 이미 존재합니다.${NC}"
    else
        mkdir $NODENAME
        echo -e "${YELLOW}/root/node/$NODENAME 디렉토리를 생성했습니다.${NC}"
    fi
    cd $NODENAME
}

# 노드 설치
installRequirements(){
    echo -e "${YELLOW}$NODENAME에 필요한 패키지 설치 중...${NC}"
    sleep 2

    if ! command -v unzip &> /dev/null; then
        echo -e "${YELLOW}Unzip 설치 중...${NC}"
        sudo apt install unzip -y
        echo -e "${GREEN}Unzip이 설치되었습니다.${NC}"
    else
        echo -e "${GREEN}Unzip이 이미 설치되어 있습니다.${NC}"
    fi

    if ! command -v ollama &> /dev/null; then
        echo -e "${YELLOW}Ollama 설치 중...${NC}"
        curl -fsSL https://ollama.com/install.sh | sh
        echo -e "${GREEN}Ollama가 설치되었습니다.${NC}"
    else
        echo -e "${GREEN}Ollama가 이미 설치되어 있습니다.${NC}"
    fi

    echo -e "${YELLOW}$NODENAME 컴퓨트 노드 설치 중...${NC}"

    # dkn-compute-node 폴더가 존재하는지 확인
    if [ -d "/root/node/$NODENAME/dkn-compute-node" ]; then
        echo -e "${GREEN}기존 dkn-compute-node 폴더가 존재합니다. 설치를 계속 진행합니다.${NC}"
    fi

    if [ -f "/root/node/$NODENAME/dkn-compute-node.zip" ]; then
        echo -e "${YELLOW}기존 dkn-compute-node.zip 파일을 삭제 중...${NC}"
        rm -f /root/node/$NODENAME/dkn-compute-node.zip
    fi

    echo -e "${YELLOW}dkn-compute-node.zip 다운로드 중...${NC}"
    curl -L -o /root/node/$NODENAME/dkn-compute-node.zip https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-amd64.zip 
    echo -e "${YELLOW}dkn-compute-node.zip 압축 해제 중...${NC}"
    unzip /root/node/$NODENAME/dkn-compute-node.zip -d /root/node/$NODENAME/  # 압축 해제 경로 지정
    rm /root/node/$NODENAME/dkn-compute-node.zip 
    cd /root/node/$NODENAME/dkn-compute-node

    echo -e "${GREEN}$NODENAME 컴퓨트 노드가 설치되었습니다.${NC}"
}

#노드 구동
run() {
    echo -e "${YELLOW}디스코드에 들어가세요: https://discord.com/invite/dria${NC}"
    echo -e "${YELLOW}노드 구동을 완료한 후 구글폼을 작성하세요: ${NC}"
    echo -e "${YELLOW}https://docs.google.com/forms/d/e/1FAIpQLSeK090ejc4dg5x1ztb_yAOxGz5o1V8JUqDa-o3AwV1Lq7NpMA/viewform?pli=1${NC}"
    echo -e "${YELLOW}대시보드사이트: https://steps.leaderboard.dria.co/${NC}"
    echo -e "${YELLOW}모델을 선택하라고 나오면 추천 모델은 다음과 같습니다: Gemini2:9b + Llama3_1_8B${NC}"
    echo -e "${YELLOW}Gemini APIKEY를 여기서 받으세요: https://aistudio.google.com/app/apikey${NC}"
    echo -e "${YELLOW}OpenAI APIKEY를 여기서 받으세요: https://platform.openai.com/api-keys${NC}"
    echo -e "${YELLOW}다음 주소에서 리더보드를 확인하세요: https://steps.leaderboard.dria.co/${NC}"
    echo -e "${GREEN}첫번째로 실행시 테스트를 시작합니다. 테스트에 통과한다면 스크린을 분리 후 다시 생성하셔서 다음 명령어를 입력하세요.${NC}"
    echo -e "${GREEN}1. cd /root/node/$NODENAME/dkn-compute-node${NC}"
    echo -e "${GREEN}2. ./dkn-compute-launcher${NC}" 
    read -p "노드를 실행하시겠습니까? (y/n): " response
    if [[ $response == "y" ]]; then
        ./dkn-compute-launcher
    else
        echo -e "${GREEN}LFG${NC}"
    fi
}

dockerSetup
setup
installRequirements
run
