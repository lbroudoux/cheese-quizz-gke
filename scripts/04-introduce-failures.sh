POD_V2=$(kubectl get pods -n cheese-quizz | grep v2 | awk '{print $1}')
kubectl exec -it $POD_V2 -- curl localhost:8080/api/cheese/flag/misbehave

POD_V3=$(kubectl get pods -n cheese-quizz | grep v3 | awk '{print $1}')
kubectl exec -it $POD_V3 -- curl localhost:8080/api/cheese/flag/timeout


kubectl scale deployment/cheese-quizz-question-v2 --replicas=2
kubectl scale deployment/cheese-quizz-question-v3 --replicas=2