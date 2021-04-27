### SSH tunneling 생성 방법

기본적인 사용법은 스크립트의 help message를 참고한다.

```bash
$ ./create_tunnel.sh -h
```
사전 준비 작업
* SSH 서버: Google Cloud에 SSH server 데몬에 remote port forwarding이 설정되어있어야 한다.
* 방화벽: 터널링 client 장비에서 나가는 SSH port가 허용되어 있어야 한다
* 터널링 client 장비에서 내부 서비스(ex: database)에 접속 가능해야 한다.
* 터널링 장비에는 crontab이 설치되어 있어야 한다.

1. SSH key 생성
    
    * ssh-keygen을 이용해 SSH 접속에 사용할 key를 생성한다.  
    
    ```bash
    # 사용 예
    $ ssh-keygen -t rsa -f ~/.ssh/id_rsa  -C "hyperlounge_collect"   
    ```   

2. SSH server에 계정 및 key 등록

    * SSH server에 계정을 생성하고 1)에서 생성한 public key를 자동 접속하기 위해 등록한다.
    이 작업은 gcloud os login이 가능한 장비에서 os login후에 수행해야 한다 .
    
    ```bash
    # 사용 예
    $ /vpc-script/enable_ssh_tunneling.sh -p hyperlounge-dev -u dev-collect -k "ssh-rsa AAAA......0OAF2rEc= hyperlounge" 10000
    ```
3. 터널링 client 장비에서 SSH tunneling 생성 

    * 터널링 client 장비에서 crontab을 이용해 주기적으로 SSH 터널생성 script를 실행한다.  
    5~10 분 주기로 터널이 끊겨 있는지 확인하고 끊긴 경우 새로운 터널을 생성한다. 

    ```bash
    # 사용 예
    $ 5 * * * * /script/create_tunnel.sh -s 34.64.84.46 -l localhost -p 8000 -k  /Users/everjs/.ssh/id_rsa_hyperlounge -u dev-collect  10000 > /dev/null 2>&1
    ```