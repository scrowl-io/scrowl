.PHONY: help start stop showLogs showLogFeed cleanStart

# Determine this makefile's path. Ensures that the $(MAKE) command uses the same makefile
THIS_FILE := $(lastword $(MAKEFILE_LIST))

### Unique variables per project
PROJECT_NAME = "SCROWL"
DOCKERHUB_PROJECT_ID = sezarosg
DOCKERHUB_REGISTRY_ID = sezarosg.io
DOCKERHUB_HOSTNAME = docker.io
DOCKERHUB_FRONTEND_IMAGE_NAME = electron_app
LOCAL_FRONTEND_CONTAINER = scrowl_electron
FRONTEND_IMAGE_TAG = ${DOCKERHUB_HOSTNAME}/${DOCKERHUB_PROJECT_ID}/${DOCKERHUB_FRONTEND_IMAGE_NAME}:$(versionTag)
FRONTEND_IMAGE_TAG_LATEST = ${DOCKERHUB_HOSTNAME}/${DOCKERHUB_PROJECT_ID}/${DOCKERHUB_FRONTEND_IMAGE_NAME}:latest
MAKEFILE_VERSION = "v1.0.0"

### Endof Unique variables per project


# Some styling presets
SET_BACKGROUND_FOREGROUND_ = `tput setab 	39; tput setaf 24`
START_HIGHLIGHT = `tput setaf 110`
START_HIGHLIGHT_SECONDARY = `tput setaf 39`
START_DESC = ${START_HIGHLIGHT}`tput smul`
STOP_STYLING = `tput sgr0`
START_STYLE_CMD_INFO = "***`tput smul`"
STOP_STYLE_CMD_INFO = `tput rmul`

# Greeting message
define INTRO
	@echo "${SET_BACKGROUND_FOREGROUND_}\n\n";
	@echo ${MAKEFILE_VERSION};
	@echo "==================================================================";
	@echo "`tput smso`*************************`tput smul; `OSG - ${PROJECT_NAME}`tput rmul`*****************************";
	@echo ${1};
	@echo "******************************************************************`tput rmso;`";
	@echo "==================================================================\n";
endef

# Information message
# $1 Title
# $2 Target name
# $3 Options with info
# $4 Options with values
define INFO_CONTAINER
	@echo "\n\n\n  CMD: make ${START_HIGHLIGHT}" \
		${2} \
		"${START_HIGHLIGHT_SECONDARY}" \
		${4} \
		"${STOP_STYLING}";
	@echo "\n  PARAMS:";
	@echo "  "${3};
	@echo "  DESC: ${START_DESC}"${1}"${STOP_STYLING}";
endef

# Delete files and folders
# $1 is the files to delete
define Delete_FILES
	@rm -rf ${1};
endef

# Delete the local image
# $1 is the image name with version tag
define CLEANUP
	@echo "\n ${START_DESC}Cleanning up${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo "docker ${START_HIGHLIGHT}rmi ${START_HIGHLIGHT_SECONDARY}-f"'$$ (docker images ${1} -q)'"${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}";

	@docker rmi -f $$(docker images ${1} -q);
endef

# Rebuild image and uploads to registry
# $1 is the the image name with version tag
# $2 is the name of the dockerfile
# $3 is the image name with latest version tag
define REBUILD_IMAGE_PUSH
	@echo "Step 1: ${START_DESC}Making sure node_modules and yarn.lock are removed${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo ' rm -rf yarn.lock node_modules';
	@echo "${STOP_STYLE_CMD_INFO}"; 
	$(call Delete_FILES, yarn.lock node_modules) 
	
	@echo "\nStep 2: ${START_DESC}Build fresh image and tag it${STOP_STYLING}"; 
	@echo "${START_STYLE_CMD_INFO}"; 
	@echo "docker ${START_HIGHLIGHT}build${START_HIGHLIGHT_SECONDARY} -f ./.docker/${2}.dockerfile -t ${1} -t ${3} .${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker build -f ./.docker/${2}.dockerfile -t ${1} -t ${3} .;

	@echo "\nStep 3: ${START_DESC}Push image to GCR${STOP_STYLING}"; 
	@echo "${START_STYLE_CMD_INFO}"; 
	@echo " docker ${START_HIGHLIGHT}push${START_HIGHLIGHT_SECONDARY} ${1}${STOP_STYLING}"; 
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker push ${1};
	@echo "${START_STYLE_CMD_INFO}"; 
	@echo " docker ${START_HIGHLIGHT}push${START_HIGHLIGHT_SECONDARY} ${3}${STOP_STYLING}"; 
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker push ${3};
endef

updateNodeImage:
	$(call INTRO,"Updating Frontend (node container) image and uploading it to registry")
	@echo "${STOP_STYLING}";

ifeq ($(strip $(versionTag)),)
	@echo " !!!!Missing an argument: make <target> <arguments>";
	@echo "For Example: make `tput smul`${START_HIGHLIGHT}updateNodeImage ${START_HIGHLIGHT_SECONDARY}versionTag=v1.0.0${STOP_STYLING}";
	@exit 1;
endif

	$(call REBUILD_IMAGE_PUSH,${FRONTEND_IMAGE_TAG},"node", ${FRONTEND_IMAGE_TAG_LATEST})
	$(call CLEANUP,${DOCKERHUB_PROJECT_ID}/${DOCKERHUB_FRONTEND_IMAGE_NAME}:$(versionTag))
	@echo "\n\n Finished.";
	@echo " Your hosted image is:"; 
	@echo " ${START_STYLE_CMD_INFO}${FRONTEND_IMAGE_TAG}${STOP_STYLE_CMD_INFO}";
	@echo " or";
	@echo " ${START_STYLE_CMD_INFO}${FRONTEND_IMAGE_TAG_LATEST}${STOP_STYLE_CMD_INFO}";

showLogFeed:
	@echo "Step 1: ${START_DESC}Start project in the forground${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker compose ${START_HIGHLIGHT}up${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker compose up;

showLogs:
	@echo "Step1: ${START_DESC}Show logs for all containers${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker compose ${START_HIGHLIGHT}logs${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker compose logs;

stop:
	$(call INTRO,"Stopping the project.                                            ")
	@echo "${STOP_STYLING}";

	@echo "Step 1: ${START_DESC}Stoping all containers (wihtout removing containers)${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker compose ${START_HIGHLIGHT}stop${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker compose stop;
	
start:
	$(call INTRO,"Starting the project.                                            ")
	@echo "${STOP_STYLING}";

	$(eval $@_step:=1)


ifneq ($(strip $(startOver)),)
	@echo "\nStep $($@_step)-1: ${START_DESC}Remove all containers and volumes${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker compose ${START_HIGHLIGHT}down ${START_HIGHLIGHT_SECONDARY}-v${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker compose down -v;

	@echo "\nStep $($@_step)-2: ${START_DESC}Let's pull the latest images from GCR${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker compose ${START_HIGHLIGHT}pull${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}";
	@docker compose pull;
	
	$(eval $@_step:=$(shell expr $($@_step) + 1))
endif

ifneq ($(strip $(logOff)),)
	@echo "\nStep $($@_step): ${START_DESC}Start project in the background${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker compose ${START_HIGHLIGHT}up ${START_HIGHLIGHT_SECONDARY}-d${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker compose up -d;

	@echo "\n\n\n* ${START_DESC}Thats it! Here are the running containers${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker compose ${START_HIGHLIGHT}ps${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker compose ps;

	@echo "\n\n\n If you would like to have a live log feed you can run:";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " make ${START_HIGHLIGHT}showLogFeed${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@echo " or\n";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker compose ${START_HIGHLIGHT}up${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}";
else
	@echo "\nStep $($@_step): ${START_DESC}Start project in the forground${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker compose ${START_HIGHLIGHT}up ";
	@echo "${STOP_STYLE_CMD_INFO}"; 
	@docker compose up;
endif



ifeq ($(wildcard ./node_modules/.),)
	$(eval $@_step:=$(shell expr $($@_step) + 1))

	@echo "\nStep $($@_step): ${START_DESC}node_modules folder is missing${STOP_STYLING}";
	@echo "Step $($@_step)-1: ${START_DESC}Ok, now lets copy the node_modules from the container${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}"
	@echo " docker ${START_HIGHLIGHT}cp${START_HIGHLIGHT_SECONDARY} "'${LOCAL_FRONTEND_CONTAINER}:/app/node_modules ./node_modules'"${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}";
	@docker cp ${LOCAL_FRONTEND_CONTAINER}:/app/node_modules ./node_modules;

	@echo "\nStep $($@_step)-2: ${START_DESC}While we are here, lets copy the yarn.lock as well${STOP_STYLING}";
	@echo "${START_STYLE_CMD_INFO}";
	@echo " docker ${START_HIGHLIGHT}cp${START_HIGHLIGHT_SECONDARY} "'${LOCAL_FRONTEND_CONTAINER}:/app/yarn.lock ./yarn.lock'"${STOP_STYLING}";
	@echo "${STOP_STYLE_CMD_INFO}";
	@docker cp ${LOCAL_FRONTEND_CONTAINER}:/app/yarn.lock ./yarn.lock;
endif 


cleanStart:
	$(call INTRO,"A clean start has some extra steps so it will take longer        ")
	@echo "${STOP_STYLING}";

	@echo "*- Making sure node_modules and yarn.lock are removed";
	@echo "${START_STYLE_CMD_INFO}";
	@echo ' rm -rf yarn.lock node_modules';
	@echo "${STOP_STYLE_CMD_INFO}";
	$(call Delete_FILES, yarn.lock node_modules) 

# Will add this when we setup AWS parameter store
#@$(MAKE) -f $(THIS_FILE) getLatestSecrets

	@$(MAKE) -f $(THIS_FILE) start startOver=true


help:
	$(call INTRO," Automate a bunch of commands to speed things up.                 ")
	@echo "${STOP_STYLING}";

#
# cleanStart
#
	$(call INFO_CONTAINER,"Gets the latest secret files then removes all containers before starting and updates your local yarn.lock as well as the node_modules folder by copying it over from the container", \
		"cleanStart", \
		"N/A\n", \
		"" \
		)
#
# updateNodeImage
#
	$(call INFO_CONTAINER,"Update Node image and push it to registry", \
		"updateNodeImage", \
		"${START_HIGHLIGHT_SECONDARY}versionTag${STOP_STYLING} -Required\n", \
		"versionTag=V1.0.0" \
		)

#
# start
#
	$(call INFO_CONTAINER,"Start project", \
		"start", \
		"${START_HIGHLIGHT_SECONDARY}startOver=true${STOP_STYLING} -Optional- removes containers and volumes first\n   ${START_HIGHLIGHT_SECONDARY}logOff=true${STOP_STYLING} -Optional- will run the project in the background\n", \
		"<Extra_options>" \
		)
		
#
# stop
#
	$(call INFO_CONTAINER,"Stop project", \
		"stop", \
		"N/A\n", \
		"" \
		)

#
# showLogFeed
#
	$(call INFO_CONTAINER,"Show a live log feed", \
		"showLogFeed", \
		"N/A\n", \
		"" \
		)

#
# showLogs
#
	$(call INFO_CONTAINER,"Show logs of all containers (not a live feed)", \
		"showLogs", \
		"N/A\n", \
		"" \
		)
