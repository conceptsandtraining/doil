#!/bin/bash

### CHANGE THIS TO /var/www/whereever
cd ../skins

# clone base skin
git clone git@github.com:conceptsandtraining/ilias-skins54.git base54
cd base54
PREFIX="origin/"
for BRANCH in $(git branch -r);
do
	if [[ "origin/HEAD -> origin/base53" != *"$BRANCH"* ]]; then
        BASEBRANCH=${BRANCH#"$PREFIX"}
		git clone git@github.com:conceptsandtraining/ilias-skins54.git ../$BASEBRANCH
		cd ../$BASEBRANCH && git checkout $BASEBRANCH && cd ../base54
	fi
done

# Make the custom folders
cd ../../ilias
git clone git@github.com:conceptsandtraining/TMS.git ilias54

cd ilias54/Customizing
mkdir global
mkdir global/plugins
mkdir global/plugins/Services
mkdir global/plugins/Services/Cron
mkdir global/plugins/Services/Cron/CronHook
mkdir global/plugins/Services/Repository
mkdir global/plugins/Services/Repository/RepositoryObject
mkdir global/plugins/Services/UIComponent
mkdir global/plugins/Services/UIComponent/UserInterfaceHook
mkdir global/plugins/Services/EventHandling
mkdir global/plugins/Services/EventHandling/EventHook
mkdir global/plugins/Modules
mkdir global/plugins/Modules/OrgUnit
mkdir global/plugins/Modules/OrgUnit/OrgUnitTypeHook

# Clone the repos to their directories
git clone git@github.com:conceptsandtraining/ilias-plugin-CSN global/plugins/Services/Repository/RepositoryObject/CSN
git clone git@github.com:conceptsandtraining/ilias-plugin-CourseSubscriptionMails global/plugins/Services/EventHandling/EventHook/CourseSubscriptionMails
git clone git@github.com:conceptsandtraining/ilias-plugin-BareContentView global/plugins/Services/UIComponent/UserInterfaceHook/BareContentView
git clone git@github.com:conceptsandtraining/ilias-plugin-ExitedUserCleanup global/plugins/Services/Cron/CronHook/ExitedUserCleanup
git clone git@github.com:conceptsandtraining/ilias-plugin-TrainingProvider global/plugins/Services/Cron/CronHook/TrainingProvider
git clone git@github.com:conceptsandtraining/ilias-plugin-ILIASSoapSSO global/plugins/Services/Repository/RepositoryObject/ILIASSoapSSO
git clone git@github.com:conceptsandtraining/ilias-plugin-AutomaticUserAdministration global/plugins/Services/Cron/CronHook/AutomaticUserAdministration
git clone git@github.com:conceptsandtraining/ilias-plugin-UserDataValidationPrompt global/plugins/Services/UIComponent/UserInterfaceHook/UserDataValidationPrompt
git clone git@github.com:conceptsandtraining/ilias-plugin-DeskRedirect global/plugins/Services/UIComponent/UserInterfaceHook/DeskRedirect
git clone git@github.com:conceptsandtraining/ilias-plugin-LoginPage global/plugins/Services/UIComponent/UserInterfaceHook/LoginPage
git clone git@github.com:conceptsandtraining/ilias-plugin-SendCertificatesAsEMailCron global/plugins/Services/Cron/CronHook/SendCertificatesAsEMailCron
git clone git@github.com:conceptsandtraining/ilias-plugin-Accounting global/plugins/Services/Repository/RepositoryObject/Accounting
git clone git@github.com:conceptsandtraining/ilias-plugin-EnhancedLPReport global/plugins/Services/Repository/RepositoryObject/EnhancedLPReport
git clone git@github.com:conceptsandtraining/ilias-plugin-MaterialList global/plugins/Services/Repository/RepositoryObject/MaterialList
git clone git@github.com:conceptsandtraining/ilias-plugin-Venues global/plugins/Services/Cron/CronHook/Venues
git clone git@github.com:conceptsandtraining/ilias-plugin-RoomSetup global/plugins/Services/Repository/RepositoryObject/RoomSetup
git clone git@github.com:conceptsandtraining/ilias-plugin-SkinUpdate global/plugins/Services/EventHandling/EventHook/SkinUpdate
git clone git@github.com:conceptsandtraining/ilias-plugin-TalentAssessment global/plugins/Services/Repository/RepositoryObject/TalentAssessment
git clone git@github.com:conceptsandtraining/ilias-plugin-CareerGoal global/plugins/Services/Repository/RepositoryObject/CareerGoal
git clone git@github.com:conceptsandtraining/ilias-plugin-TalentAssessmentReport global/plugins/Services/Repository/RepositoryObject/TalentAssessmentReport
git clone git@github.com:conceptsandtraining/ilias-plugin-UserAgreementEditor global/plugins/Services/Cron/CronHook/UserAgreementEditor
git clone git@github.com:conceptsandtraining/ilias-plugin-CourseClassification global/plugins/Services/Repository/RepositoryObject/CourseClassification
git clone git@github.com:conceptsandtraining/ilias-plugin-StudyProgrammeAutoAssignment global/plugins/Services/EventHandling/EventHook/StudyProgrammeAutoAssignment
git clone git@github.com:conceptsandtraining/ilias-plugin-BookingModalities global/plugins/Services/Repository/RepositoryObject/BookingModalities
git clone git@github.com:conceptsandtraining/ilias-plugin-Webinar global/plugins/Services/Repository/RepositoryObject/Webinar
git clone git@github.com:conceptsandtraining/ilias-plugin-CourseClassificationEventHook global/plugins/Services/EventHandling/EventHook/CourseClassificationEventHook
git clone git@github.com:conceptsandtraining/ilias-plugin-Accomodation global/plugins/Services/Repository/RepositoryObject/Accomodation
git clone git@github.com:conceptsandtraining/ilias-plugin-CopySettings global/plugins/Services/Repository/RepositoryObject/CopySettings
git clone git@github.com:conceptsandtraining/ilias-plugin-CourseMailing global/plugins/Services/Repository/RepositoryObject/CourseMailing
git clone git@github.com:conceptsandtraining/ilias-plugin-Cockpit global/plugins/Services/UIComponent/UserInterfaceHook/Cockpit
git clone git@github.com:conceptsandtraining/ilias-plugin-UserBookings global/plugins/Services/Repository/RepositoryObject/UserBookings
git clone git@github.com:conceptsandtraining/ilias-plugin-CourseMember global/plugins/Services/Repository/RepositoryObject/CourseMember
git clone git@github.com:conceptsandtraining/ilias-plugin-ScaledFeedback global/plugins/Services/Repository/RepositoryObject/ScaledFeedback
git clone git@github.com:conceptsandtraining/ilias-plugin-UserCourseHistorizing global/plugins/Services/Cron/CronHook/UserCourseHistorizing
git clone git@github.com:conceptsandtraining/ilias-plugin-EduBiography global/plugins/Services/Repository/RepositoryObject/EduBiography
git clone git@github.com:conceptsandtraining/ilias-plugin-TrainingAssignments global/plugins/Services/Repository/RepositoryObject/TrainingAssignments
git clone git@github.com:conceptsandtraining/ilias-plugin-ScheduledEvents global/plugins/Services/Cron/CronHook/ScheduledEvents
git clone git@github.com:conceptsandtraining/ilias-plugin-EduTracking global/plugins/Services/Repository/RepositoryObject/EduTracking
git clone git@github.com:conceptsandtraining/ilias-plugin-TrainingAdminOverview global/plugins/Services/Repository/RepositoryObject/TrainingAdminOverview
git clone git@github.com:conceptsandtraining/ilias-plugin-AgendaItemPool global/plugins/Services/Repository/RepositoryObject/AgendaItemPool
git clone git@github.com:conceptsandtraining/ilias-plugin-CronJobSurveillance global/plugins/Services/Cron/CronHook/CronJobSurveillance
git clone git@github.com:conceptsandtraining/ilias-plugin-Agenda global/plugins/Services/Repository/RepositoryObject/Agenda
git clone git@github.com:conceptsandtraining/ilias-plugin-CourseCreation global/plugins/Services/Cron/CronHook/CourseCreation
git clone git@github.com:conceptsandtraining/ilias-plugin-StatusMails global/plugins/Services/Cron/CronHook/StatusMails
git clone git@github.com:conceptsandtraining/ilias-plugin-TrainingDemandAdvanced global/plugins/Services/Repository/RepositoryObject/TrainingDemandAdvanced
git clone git@github.com:conceptsandtraining/ilias-plugin-TrainingDemandRetarded global/plugins/Services/Repository/RepositoryObject/TrainingDemandRetarded
git clone git@github.com:conceptsandtraining/ilias-plugin-TrainingStatistics global/plugins/Services/Repository/RepositoryObject/TrainingStatistics
git clone git@github.com:conceptsandtraining/ilias-plugin-BookingApprovals global/plugins/Services/Repository/RepositoryObject/BookingApprovals
git clone git@github.com:conceptsandtraining/ilias-plugin-EmployeeBookingOverview global/plugins/Services/Repository/RepositoryObject/EmployeeBookingOverview
git clone git@github.com:conceptsandtraining/ilias-plugin-WBDCrsHistorizing global/plugins/Services/Cron/CronHook/WBDCrsHistorizing
git clone git@github.com:conceptsandtraining/ilias-plugin-TrainingSearch global/plugins/Services/Repository/RepositoryObject/TrainingSearch
git clone git@github.com:conceptsandtraining/ilias-plugin-BookingAcknowledge global/plugins/Services/Repository/RepositoryObject/BookingAcknowledge
git clone git@github.com:conceptsandtraining/ilias-plugin-OrguByMailDomain global/plugins/Services/EventHandling/EventHook/OrguByMailDomain
git clone git@github.com:conceptsandtraining/ilias-plugin-TrainerOperations global/plugins/Services/Repository/RepositoryObject/TrainerOperations
git clone git@github.com:conceptsandtraining/ilias-plugin-SyncExtCalendars global/plugins/Services/Cron/CronHook/SyncExtCalendars
git clone git@github.com:conceptsandtraining/ilias-plugin-AutomaticCancelWaitinglist global/plugins/Services/Cron/CronHook/AutomaticCancelWaitinglist
git clone git@github.com:conceptsandtraining/ilias-plugin-WorkflowReminder global/plugins/Services/Cron/CronHook/WorkflowReminder
git clone git@github.com:conceptsandtraining/ilias-plugin-CancellationFeeReport global/plugins/Services/Repository/RepositoryObject/CancellationFeeReport
git clone git@github.com:conceptsandtraining/ilias-plugin-TrainingStatisticsByOrgUnits global/plugins/Modules/OrgUnit/OrgUnitTypeHook/TrainingStatisticsByOrgUnits
git clone git@github.com:conceptsandtraining/ilias-plugin-WBDCommunicator global/plugins/Services/Cron/CronHook/WBDCommunicator
git clone git@github.com:conceptsandtraining/ilias-plugin-WBDManagement global/plugins/Services/Repository/RepositoryObject/WBDManagement
git clone git@github.com:conceptsandtraining/ilias-plugin-WBDReport global/plugins/Services/Repository/RepositoryObject/WBDReport
git clone git@github.com:conceptsandtraining/ilias-plugin-ParticipationsImport global/plugins/Services/Cron/CronHook/ParticipationsImport
