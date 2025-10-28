/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared

extension PhotonActionSheetProtocol {

    //Returns a list of actions which is used to build a menu
    //OpenURL is a closure that can open a given URL in some view controller. It is up to the class using the menu to know how to open it
    func getLibraryActions(vcDelegate: PageOptionsVC) -> [PhotonActionSheetItem] {
        guard let tab = self.tabManager.selectedTab else { return [] }

        let openLibrary = PhotonActionSheetItem(title: Strings.AppMenuLibraryTitleString, iconString: "menu-library") { _, _ in
            let bvc = vcDelegate as? BrowserViewController
            bvc?.showLibrary()
        }

        let openHomePage = PhotonActionSheetItem(title: Strings.AppMenuOpenHomePageTitleString, iconString: "menu-Home") { _, _ in
            if let string = UserDefaults.standard.string(forKey: Constant.homeURLKey()),
                let url = URL(string: string)
            {
                tab.loadRequest(URLRequest(url: url))
            }
        }

        return [openHomePage, openLibrary]
    }

    func getOtherPanelActions(vcDelegate: PageOptionsVC) -> [PhotonActionSheetItem] {
        let openSettings = PhotonActionSheetItem(title: Strings.AppMenuSettingsTitleString, iconString: "menu-Settings") { _, _ in
            let settingsTableViewController = AppSettingsTableViewController()
            settingsTableViewController.profile = self.profile
            settingsTableViewController.tabManager = self.tabManager
            settingsTableViewController.settingsDelegate = vcDelegate

            let controller = ThemedNavigationController(rootViewController: settingsTableViewController)
            // On iPhone iOS13 the WKWebview crashes while presenting file picker if its not full screen. Ref #6232
            if UIDevice.current.userInterfaceIdiom == .phone {
                controller.modalPresentationStyle = .fullScreen
            }
            controller.presentingModalViewControllerDelegate = vcDelegate

            // Wait to present VC in an async dispatch queue to prevent a case where dismissal
            // of this popover on iPad seems to block the presentation of the modal VC.
            DispatchQueue.main.async {
                vcDelegate.present(controller, animated: true, completion: nil)
            }
        }
        return [openSettings]
    }
}
