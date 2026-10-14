import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

// SANVOICE sign-in: one small portrait window, as in the Ringotel desktop app.
// Domain (with arrow), extension, password. A second panel takes an invite link.
Rectangle {
	id: mainItem
	objectName: "sanvoiceLoginPage"
	color: DefaultStyle.grey_0

	// A computer stays online, so it registers straight to the tenant's PBX over TLS
	// (like a desk phone). Only mobile apps go through the push gateway: if both used it,
	// the PBX would send one call per gateway registration and each device would ring twice.
	readonly property string invitePrefix: "https://prov.sanvoice.com/"
	property bool inviteMode: false
	property string localError: ""
	readonly property bool busy: LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Progress
	readonly property string shownError: localError.length > 0 ? localError : LoginPageCpp.errorMessage

	function validDomain(domain) {
		return /^([a-z0-9-]+\.)+sanvoice\.com$/.test(domain)
	}
	function submitLogin() {
		localError = ""
		var domain = domainField.text.trim().toLowerCase()
		var extension = extensionField.text.trim()
		if (!validDomain(domain)) {
			localError = qsTr("Enter your SANVOICE domain, for example office.sanvoice.com.")
			domainField.forceActiveFocus()
			return
		}
		if (extension.length === 0) {
			localError = qsTr("Enter your extension.")
			extensionField.forceActiveFocus()
			return
		}
		if (passwordField.text.length === 0) {
			localError = qsTr("Enter your password.")
			passwordField.forceActiveFocus()
			return
		}
		LoginPageCpp.login(extension, passwordField.text, "", domain, LinphoneEnums.TransportType.Tls,
		                   "", "", "")
	}
	function submitInvite() {
		localError = ""
		var link = inviteField.text.trim()
		if (link.indexOf(mainItem.invitePrefix) !== 0) {
			localError = qsTr("That doesn't look like a SANVOICE invite link.")
			inviteField.forceActiveFocus()
			return
		}
		UtilsCpp.useFetchConfig(link)
	}

	// Faint icon pattern, drawn from the app's own icons.
	Repeater {
		model: [
			{"icon": AppIcons.phone, "x": -0.06, "y": 0.10, "s": 64},
			{"icon": AppIcons.microphone, "x": 0.70, "y": 0.06, "s": 44},
			{"icon": AppIcons.envelope, "x": -0.04, "y": 0.38, "s": 52},
			{"icon": AppIcons.lock, "x": 0.82, "y": 0.34, "s": 48},
			{"icon": AppIcons.adressBook, "x": 0.06, "y": 0.62, "s": 56},
			{"icon": AppIcons.voicemail, "x": 0.76, "y": 0.60, "s": 52},
			{"icon": AppIcons.phone, "x": 0.14, "y": 0.84, "s": 46},
			{"icon": AppIcons.envelope, "x": 0.70, "y": 0.82, "s": 60}
		]
		EffectImage {
			z: 0
			x: modelData.x * mainItem.width
			y: modelData.y * mainItem.height
			width: Utils.getSizeWithScreenRatio(modelData.s)
			height: width
			imageSource: modelData.icon
			colorizationColor: DefaultStyle.main1_500_main
			opacity: 0.07
			fillMode: Image.PreserveAspectFit
		}
	}

	component SanvoiceField: Control.TextField {
		id: control
		Layout.fillWidth: true
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(48)
		leftPadding: Utils.getSizeWithScreenRatio(14)
		rightPadding: Utils.getSizeWithScreenRatio(14)
		font.pixelSize: Utils.getSizeWithScreenRatio(16)
		color: DefaultStyle.main2_800
		placeholderTextColor: DefaultStyle.main2_400
		selectByMouse: true
		enabled: !mainItem.busy
		background: Rectangle {
			radius: Utils.getSizeWithScreenRatio(8)
			color: DefaultStyle.grey_0
			border.width: 1
			border.color: control.activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_200
		}
	}

	component SanvoiceButton: Control.Button {
		id: control
		Layout.fillWidth: true
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(48)
		enabled: !mainItem.busy
		background: Rectangle {
			radius: Utils.getSizeWithScreenRatio(8)
			color: !control.enabled ? DefaultStyle.main1_300
				: control.pressed ? DefaultStyle.main1_700
				: control.hovered ? DefaultStyle.main1_600 : DefaultStyle.main1_500_main
		}
		contentItem: Text {
			text: control.text
			color: DefaultStyle.grey_0
			font.pixelSize: Utils.getSizeWithScreenRatio(17)
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}
	}

	ColumnLayout {
		z: 1
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: Utils.getSizeWithScreenRatio(48)
		width: Math.min(parent.width - Utils.getSizeWithScreenRatio(64), Utils.getSizeWithScreenRatio(360))
		spacing: Utils.getSizeWithScreenRatio(12)

		Image {
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(110)
			Layout.preferredHeight: Utils.getSizeWithScreenRatio(110)
			source: AppIcons.splashscreenLogo
			sourceSize.width: Utils.getSizeWithScreenRatio(220)
			sourceSize.height: Utils.getSizeWithScreenRatio(220)
			fillMode: Image.PreserveAspectFit
		}
		Item { Layout.preferredHeight: Utils.getSizeWithScreenRatio(18) }

		// Sign in with domain, extension and password.
		ColumnLayout {
			Layout.fillWidth: true
			visible: !mainItem.inviteMode
			spacing: Utils.getSizeWithScreenRatio(12)

			RowLayout {
				Layout.fillWidth: true
				spacing: 0
				SanvoiceField {
					id: domainField
					placeholderText: "office.sanvoice.com"
					inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
					onAccepted: arrowButton.clicked()
					KeyNavigation.tab: extensionField
				}
				Control.Button {
					id: arrowButton
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(52)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(48)
					enabled: !mainItem.busy
					background: Rectangle {
						radius: Utils.getSizeWithScreenRatio(8)
						color: arrowButton.hovered ? DefaultStyle.main1_600 : DefaultStyle.main1_500_main
					}
					contentItem: EffectImage {
						imageSource: AppIcons.arrowRight
						colorizationColor: DefaultStyle.grey_0
						fillMode: Image.PreserveAspectFit
						width: Utils.getSizeWithScreenRatio(22)
						height: width
					}
					onClicked: {
						mainItem.localError = ""
						if (mainItem.validDomain(domainField.text.trim().toLowerCase())) extensionField.forceActiveFocus()
						else {
							mainItem.localError = qsTr("Enter your SANVOICE domain, for example office.sanvoice.com.")
							domainField.forceActiveFocus()
						}
					}
				}
			}
			SanvoiceField {
				id: extensionField
				placeholderText: qsTr("Extension")
				inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
				onAccepted: passwordField.forceActiveFocus()
				KeyNavigation.tab: passwordField
			}
			SanvoiceField {
				id: passwordField
				placeholderText: qsTr("Password")
				echoMode: TextInput.Password
				rightPadding: Utils.getSizeWithScreenRatio(48)
				onAccepted: mainItem.submitLogin()
				EffectImage {
					anchors.right: parent.right
					anchors.rightMargin: Utils.getSizeWithScreenRatio(14)
					anchors.verticalCenter: parent.verticalCenter
					width: Utils.getSizeWithScreenRatio(22)
					height: width
					imageSource: passwordField.echoMode === TextInput.Password ? AppIcons.eyeHide : AppIcons.eyeShow
					colorizationColor: DefaultStyle.main2_500_main
					fillMode: Image.PreserveAspectFit
					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						onClicked: passwordField.echoMode = passwordField.echoMode === TextInput.Password
							? TextInput.Normal : TextInput.Password
					}
				}
			}
			Text {
				Layout.fillWidth: true
				visible: mainItem.shownError.length > 0
				text: mainItem.shownError
				color: DefaultStyle.danger_500_main
				wrapMode: Text.WordWrap
				font.pixelSize: Utils.getSizeWithScreenRatio(14)
			}
			Item { Layout.preferredHeight: Utils.getSizeWithScreenRatio(6) }
			SanvoiceButton {
				text: mainItem.busy ? qsTr("Signing in…") : qsTr("Log in")
				onClicked: mainItem.submitLogin()
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				text: qsTr("Have an invite link?")
				color: DefaultStyle.main1_500_main
				font.pixelSize: Utils.getSizeWithScreenRatio(14)
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: {
						mainItem.localError = ""
						mainItem.inviteMode = true
						inviteField.forceActiveFocus()
					}
				}
			}
		}

		// Sign in with the link from the invite email.
		ColumnLayout {
			Layout.fillWidth: true
			visible: mainItem.inviteMode
			spacing: Utils.getSizeWithScreenRatio(12)
			Text {
				Layout.fillWidth: true
				text: qsTr("Sign in with an invite link")
				color: DefaultStyle.main2_900
				font.pixelSize: Utils.getSizeWithScreenRatio(20)
				horizontalAlignment: Text.AlignHCenter
			}
			Text {
				Layout.fillWidth: true
				text: qsTr("Paste the link from your invite email. It sets up your extension for you, and works once.")
				color: DefaultStyle.main2_600
				wrapMode: Text.WordWrap
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: Utils.getSizeWithScreenRatio(14)
			}
			SanvoiceField {
				id: inviteField
				placeholderText: "https://prov.sanvoice.com/…"
				onAccepted: mainItem.submitInvite()
			}
			Text {
				Layout.fillWidth: true
				visible: mainItem.localError.length > 0
				text: mainItem.localError
				color: DefaultStyle.danger_500_main
				wrapMode: Text.WordWrap
				font.pixelSize: Utils.getSizeWithScreenRatio(14)
			}
			SanvoiceButton {
				text: qsTr("Continue")
				onClicked: mainItem.submitInvite()
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				text: qsTr("Back to log in")
				color: DefaultStyle.main1_500_main
				font.pixelSize: Utils.getSizeWithScreenRatio(14)
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: {
						mainItem.localError = ""
						mainItem.inviteMode = false
					}
				}
			}
		}
	}

	ColumnLayout {
		z: 1
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: Utils.getSizeWithScreenRatio(22)
		spacing: 0
		Text {
			Layout.alignment: Qt.AlignHCenter
			text: "SANVOICE"
			font.pixelSize: Utils.getSizeWithScreenRatio(17)
			font.letterSpacing: 1.5
			font.weight: Font.DemiBold
			color: DefaultStyle.main2_900
		}
		Text {
			Layout.alignment: Qt.AlignHCenter
			text: qsTr("Business phone")
			font.pixelSize: Utils.getSizeWithScreenRatio(11)
			color: DefaultStyle.main2_500_main
		}
	}
}
