//
//  AKFullscreenActionSheet.swift
//  AKFullscreenActionSheet
//
//  Created by Alexander Kolov on 2020-07-07.
//  Copyright © 2020 Alexander Kolov. All rights reserved.
//

import AKButton
import UIKit

open class AKFullscreenActionSheet: UIViewController {

  public struct Configuration {
    public var contentInset: UIEdgeInsets
    public var contentSpacing: CGFloat
    public var middleContentSpacing: CGFloat
    public var bottomContentSpacing: CGFloat
    public var headerTextColor: UIColor
    public var headerFont: UIFont
    public var textColor: UIColor
    public var textFont: UIFont
    public var actionButtonConfiguration: AKButton.Configuration
    public var cancelButtonConfiguration: AKButton.Configuration

    public init(
      contentInset: UIEdgeInsets = .init(top: 32, left: 32, bottom: 32, right: 32),
      contentSpacing: CGFloat = 40,
      middleContentSpacing: CGFloat = 25,
      bottomContentSpacing: CGFloat = 8,
      headerTextColor: UIColor = {
        if #available(iOS 13.0, *) {
          return .label
        }
        else {
          return .black
        }
      }(),
      headerFont: UIFont = .preferredFont(forTextStyle: .title1),
      textColor: UIColor = {
        if #available(iOS 13.0, *) {
          return .secondaryLabel
        }
        else {
          return .gray
        }
      }(),
      textFont: UIFont = .preferredFont(forTextStyle: .body),
      actionButtonConfiguration: AKButton.Configuration = .init(),
      cancelButtonConfiguration: AKButton.Configuration = .init(backgroundColor: .clear, foregroundColor: .systemBlue)
    ) {
      self.contentInset = contentInset
      self.contentSpacing = contentSpacing
      self.middleContentSpacing = middleContentSpacing
      self.bottomContentSpacing = bottomContentSpacing
      self.headerTextColor = headerTextColor
      self.headerFont = headerFont
      self.textColor = textColor
      self.textFont = textFont
      self.actionButtonConfiguration = actionButtonConfiguration
      self.cancelButtonConfiguration = cancelButtonConfiguration
    }
  }

  // MARK: Properties

  public var action: ((AKFullscreenActionSheet) -> Void)?
  public var cancel: ((AKFullscreenActionSheet) -> Void)?

  public var onAppear: ((AKFullscreenActionSheet) -> Void)?

  public var configuration: Configuration {
    didSet {
      configure()
    }
  }

  // MARK: Subviews

  public private(set) lazy var containerView: UIStackView = {
    let containerView = UIStackView()
    containerView.axis = .vertical
    containerView.isLayoutMarginsRelativeArrangement = true
    containerView.translatesAutoresizingMaskIntoConstraints = false
    return containerView
  }()

  public private(set) lazy var topContainerView: UIView = {
    let topContainerView = UIView()
    topContainerView.backgroundColor = .clear
    topContainerView.translatesAutoresizingMaskIntoConstraints = false
    return topContainerView
  }()

  public private(set) lazy var middleContainerView: UIStackView = {
    let middleContainerView = UIStackView()
    middleContainerView.axis = .vertical
    middleContainerView.translatesAutoresizingMaskIntoConstraints = false
    return middleContainerView
  }()

  public private(set) lazy var bottomContainerView: UIStackView = {
    let bottomContainerView = UIStackView()
    bottomContainerView.axis = .vertical
    bottomContainerView.distribution = .fillEqually
    bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
    return bottomContainerView
  }()

  public private(set) lazy var headerLabel: UILabel = {
    let headerLabel = UILabel()
    headerLabel.numberOfLines = 0
    headerLabel.textAlignment = .center
    headerLabel.text = "Header Placeholder"
    headerLabel.translatesAutoresizingMaskIntoConstraints = false
    return headerLabel
  }()

  public private(set) lazy var textLabel: UILabel = {
    let textLabel = UILabel()
    textLabel.numberOfLines = 0
    textLabel.textAlignment = .center
    textLabel.text =
    """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc efficitur odio ut pulvinar pharetra. \
    Donec tempor, ante quis pretium finibus, sapien enim rutrum augue, et commodo turpis mauris ac sem.
    """
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    return textLabel
  }()

  public private(set) lazy var actionButton: AKButton = {
    let actionButton = AKButton(configuration: self.configuration.actionButtonConfiguration)
    actionButton.title = "PERFORM ACTION"
    return actionButton
  }()

  public private(set) lazy var cancelButton: AKButton = {
    let cancelButton = AKButton(configuration: self.configuration.cancelButtonConfiguration)
    cancelButton.title = "CANCEL"
    return cancelButton
  }()

  // MARK: Initializers

  public init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
    super.init(nibName: nil, bundle: nil)
    self.configure()
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    let spacer = UIView()
    spacer.backgroundColor = .clear
    spacer.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(containerView)
    containerView.addArrangedSubview(topContainerView)
    containerView.addArrangedSubview(middleContainerView)
    containerView.addArrangedSubview(spacer)
    containerView.addArrangedSubview(bottomContainerView)

    containerView.setCustomSpacing(0, after: spacer)

    middleContainerView.addArrangedSubview(headerLabel)
    middleContainerView.addArrangedSubview(textLabel)

    bottomContainerView.addArrangedSubview(actionButton)
    bottomContainerView.addArrangedSubview(cancelButton)

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    NSLayoutConstraint.activate([
      topContainerView.widthAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 1)
    ])

    NSLayoutConstraint.activate([
      actionButton.heightAnchor.constraint(equalToConstant: 48)
    ])

    headerLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    textLabel.setContentCompressionResistancePriority(.required, for: .vertical)

    actionButton.action = { [weak self] in
      if let self = self {
        self.action?(self)
      }
    }

    cancelButton.action = { [weak self] in
      if let self = self {
        self.cancel?(self)
      }
    }
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    onAppear?(self)
  }

  // MARK: Private methods

  private func configure() {
    containerView.spacing = configuration.contentSpacing
    containerView.layoutMargins = configuration.contentInset
    middleContainerView.spacing = configuration.middleContentSpacing
    bottomContainerView.spacing = configuration.bottomContentSpacing
    headerLabel.textColor = configuration.headerTextColor
    headerLabel.font = configuration.headerFont
    textLabel.textColor = configuration.textColor
    textLabel.font = configuration.textFont
    actionButton.configuration = configuration.actionButtonConfiguration
    cancelButton.configuration = configuration.cancelButtonConfiguration
  }

}
