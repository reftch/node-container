
APP_NAME?=demo-app
DOCKER?=docker
TAG?=16-alpine
PORT?=3000
APP_DIR?=app
SSR_DIR?=server

.PHONY: clean init app prod prod-run

clean:
	rm -rf .pnpm-store
	rm -rf ${APP_DIR}/node_modules
	rm -rf ${APP_DIR}/dist
	rm -f ${APP_DIR}/pnpm-lock.yaml
	rm -rf ${SSR_DIR}/node_modules
	rm -rf ${SSR_DIR}/dist
	rm -f ${SSR_DIR}/pnpm-lock.yaml

clean-docker:
	${DOCKER} image prune -a -f 

init:
	${DOCKER} build \
		-f .config/docker-config/Dockerfile.development . \
		-t ${APP_NAME}:${TAG} \
		--build-arg TAG=${TAG} \
		--no-cache
	${DOCKER} container run \
		--name ${APP_NAME}-dev \
		--rm \
		-t \
		-v "${CURDIR}":/app \
		-e APP_DIR=${APP_DIR} \
		${APP_NAME}:${TAG} \
		.config/docker-config/install.sh

dev:
	${DOCKER} container run \
		--name ${APP_NAME} \
		--rm \
		-t \
		-p ${PORT}:3000 \
		-v "${CURDIR}":/app \
		${APP_NAME}:${TAG} \
		-c "cd /app/${APP_DIR} && pnpm $(filter-out $@,$(MAKECMDGOALS))" 

prod:
	${DOCKER} container run \
		--name ${APP_NAME}-dev \
		--rm \
		-t \
		-v "${CURDIR}":/app \
		-e APP_DIR=${SSR_DIR} \
		${APP_NAME}:${TAG} \
		.config/docker-config/build.sh     
	${DOCKER} build \
		-f .config/docker-config/Dockerfile.production . \
		-t ${APP_NAME}-production:${TAG} 

prod-run:
	${DOCKER} container run \
	  --name ${APP_NAME}-production -d -t \
    -p ${PORT}:${PORT} \
		${APP_NAME}-production:${TAG}

prod-start:
	${DOCKER} container start ${APP_NAME}-production 

prod-stop:
	${DOCKER} container stop -t 2 ${APP_NAME}-production 

prod-remove:
	${DOCKER} container rm ${APP_NAME}-production 

prod-logs:
	${DOCKER} container logs -f ${APP_NAME}-production 

vite-sh:                                                                                                                                                                                                                                                                            
	docker exec -it ${APP_NAME} /bin/sh    

%:
	@:
# ref: https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line
