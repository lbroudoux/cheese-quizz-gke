kubectl apply -f istiofiles/dr-cheese-quizz-question.yml
kubectl apply -f istiofiles/vs-cheese-quizz-question-v1.yml
kubectl scale deployment/cheese-quizz-question-v2 --replicas=1
kubectl scale deployment/cheese-quizz-question-v3 --replicas=1