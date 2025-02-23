# K8S self-hosted runner 운영하기

## Prerequisite
- `pozaai` 깃허브 계정에 self-hosted runner를 운영하고자 하는 레포지토리의 관리자 관한을 부여해야 합니다.

## Adding a new self-hosted runner
```yaml
ex)
runnerTerrapo:
    name: runner-terrapo
    repository: POZAlabs/terrapo
    labels:
        - terrapo
```
- 이후, `actions-runner/values.yaml`에 값을 추가합니다.
- 마지막으로, actions-runner/ 에서 해당 Helm Chart를 배포합니다.
    - `values.yaml`을 수정하고 `main` 브랜치에 푸시하면 자동으로 self-hosted runner가 해당 레포지토리에 추가됩니다.

## Using the deployed self-hosted runner
```yaml
jobs:
    <job-name>:
        runs-on: <self-hosted runner label>
```
- 새로운 runner에 반영한 `labels`를 `<self-hosted runner label>`에 명시하면 됩니다.