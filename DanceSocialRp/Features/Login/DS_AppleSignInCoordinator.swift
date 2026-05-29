//
//  DS_AppleSignInCoordinator.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/29.
//

import AuthenticationServices
import Toast_Swift
import UIKit

/// 处理 Sign in with Apple 授权与登录分流
final class DS_AppleSignInCoordinator: NSObject {

    private weak var presentingViewController: UIViewController?

    func startSignIn(from viewController: UIViewController) {
        presentingViewController = viewController

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func handleAuthorization(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        let subject = credential.user
        if DS_CurrentUser.shared.signInWithAppleSubject(subject) {
            return
        }

        let suggestedName = Self.formattedName(from: credential.fullName)
        let setupVC = DS_SetupInfoVC(source: .apple(subject: subject, suggestedName: suggestedName))
        presentingViewController?.navigationController?.pushViewController(setupVC, animated: true)
    }

    private func handleError(_ error: Error) {
        let nsError = error as NSError
        if nsError.domain == ASAuthorizationError.errorDomain,
           nsError.code == ASAuthorizationError.canceled.rawValue {
            return
        }
        presentingViewController?.view.makeToast("Apple sign in failed. Please try again.")
    }

    private static func formattedName(from components: PersonNameComponents?) -> String? {
        guard let components else { return nil }
        let formatter = PersonNameComponentsFormatter()
        let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? nil : name
    }
}

extension DS_AppleSignInCoordinator: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        handleAuthorization(authorization)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        handleError(error)
    }
}

extension DS_AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        presentingViewController?.view.window ?? ASPresentationAnchor()
    }
}
