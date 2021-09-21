//
//  AKFullscreenActionSheet.swift
//  AKFullscreenActionSheet
//
//  Created by Alexander Kolov on 2020-07-07.
//  Copyright © 2020 Alexander Kolov. All rights reserved.
//

import AKButton
import BonMot
import UIKit

open class AKFullscreenActionSheet: UIViewController {

  public struct Configuration {
    public var contentInset: UIEdgeInsets
    public var contentSpacing: CGFloat
    public var middleContentSpacing: CGFloat
    public var bottomContentSpacing: CGFloat
    public var headerStringStyle: BonMot.StringStyle
    public var textStringStyle: BonMot.StringStyle
    public var buttonHeight: CGFloat
    public var primaryButtonConfiguration: AKButton.Configuration
    public var secondaryButtonConfiguration: AKButton.Configuration

    public init(
      contentInset: UIEdgeInsets = .init(top: 32, left: 32, bottom: 32, right: 32),
      contentSpacing: CGFloat = 40,
      middleContentSpacing: CGFloat = 25,
      bottomContentSpacing: CGFloat = 8,
      headerStringStyle: BonMot.StringStyle = BonMot.StringStyle(
        .color({
          if #available(iOS 13.0, *) {
            return .label
          }
          else {
            return .black
          }
        }()),
        .font(.preferredFont(forTextStyle: .title1))
      ),
      textStringStyle: BonMot.StringStyle = BonMot.StringStyle(
        .color({
          if #available(iOS 13.0, *) {
            return .secondaryLabel
          }
          else {
            return .gray
          }
        }()),
        .font(.preferredFont(forTextStyle: .body))
      ),
      buttonHeight: CGFloat = 40,
      primaryButtonConfiguration: AKButton.Configuration = .init(),
      secondaryButtonConfiguration: AKButton.Configuration = .init(
        backgroundColor: { _ in .clear },
        foregroundColor: { $0 == .disabled ? .systemGray : .systemBlue }
      )
    ) {
      self.contentInset = contentInset
      self.contentSpacing = contentSpacing
      self.middleContentSpacing = middleContentSpacing
      self.bottomContentSpacing = bottomContentSpacing
      self.headerStringStyle = headerStringStyle
      self.textStringStyle = textStringStyle
      self.buttonHeight = buttonHeight
      self.primaryButtonConfiguration = primaryButtonConfiguration
      self.secondaryButtonConfiguration = secondaryButtonConfiguration
    }
  }

  // MARK: Properties

  public var primaryAction: ((AKFullscreenActionSheet) -> Void)?
  public var secondaryAction: ((AKFullscreenActionSheet) -> Void)?

  public var headerLabelObserver: NSKeyValueObservation?
  public var textLabelObserver: NSKeyValueObservation?

  public var onAppear: ((AKFullscreenActionSheet) -> Void)?

  public var configuration: Configuration {
    didSet {
      configure()
    }
  }

  private weak var primaryButtonHeightConstraint: NSLayoutConstraint?

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
    headerLabel.attributedText = "Header Placeholder".styled(with: configuration.headerStringStyle)
    headerLabel.translatesAutoresizingMaskIntoConstraints = false
    return headerLabel
  }()

  public private(set) lazy var textLabel: UILabel = {
    let textLabel = UILabel()
    textLabel.numberOfLines = 0
    textLabel.textAlignment = .center
    textLabel.attributedText =
    """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc efficitur odio ut pulvinar pharetra. \
    Donec tempor, ante quis pretium finibus, sapien enim rutrum augue, et commodo turpis mauris ac sem.
    """.styled(with: configuration.textStringStyle)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    return textLabel
  }()

  public private(set) lazy var primaryButton: AKButton = {
    let primaryButton = AKButton(configuration: self.configuration.primaryButtonConfiguration)
    primaryButton.title = { _ in "PRIMARY ACTION" }
    return primaryButton
  }()

  public private(set) lazy var secondaryButton: AKButton = {
    let secondaryButton = AKButton(configuration: self.configuration.secondaryButtonConfiguration)
    secondaryButton.title = { _ in "SECONDARY ACTION" }
    return secondaryButton
  }()

  public let bottomSpacer: UIView = {
    let bottomSpacer = UIView()
    bottomSpacer.backgroundColor = .clear
    bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
    return bottomSpacer
  }()

  // MARK: Initializers

  public init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
    super.init(nibName: nil, bundle: nil)
    self.configure()

    headerLabelObserver = headerLabel.observe(\.text) { [unowned self] label, _ in
      let newText = label.text?.styled(with: self.configuration.headerStringStyle)
      if label.attributedText != newText {
        label.attributedText = newText
      }
    }

    textLabelObserver = textLabel.observe(\.text) { [unowned self] label, _ in
      let newText = label.text?.styled(with: self.configuration.textStringStyle)
      if label.attributedText != newText {
        label.attributedText = newText
      }
    }
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("Not implemented")
  }

  // MARK: View Lifecycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(containerView)
    containerView.addArrangedSubview(topContainerView)
    containerView.addArrangedSubview(middleContainerView)
    containerView.addArrangedSubview(bottomSpacer)
    containerView.addArrangedSubview(bottomContainerView)
    containerView.setCustomSpacing(0, after: bottomSpacer)

    middleContainerView.addArrangedSubview(headerLabel)
    middleContainerView.addArrangedSubview(textLabel)

    bottomContainerView.addArrangedSubview(primaryButton)
    bottomContainerView.addArrangedSubview(secondaryButton)

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    NSLayoutConstraint.activate([
      {
        let constraint = topContainerView.widthAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 1)
        constraint.priority = .defaultHigh
        return constraint
      }()
    ])

    primaryButtonHeightConstraint = primaryButton.heightAnchor.constraint(equalToConstant: configuration.buttonHeight)
    primaryButtonHeightConstraint?.isActive = true

    headerLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    textLabel.setContentCompressionResistancePriority(.required, for: .vertical)

    primaryButton.action = { [weak self] in
      if let self = self {
        self.primaryAction?(self)
      }
    }

    secondaryButton.action = { [weak self] in
      if let self = self {
        self.secondaryAction?(self)
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
    headerLabel.attributedText = headerLabel.text?.styled(with: configuration.headerStringStyle)
    textLabel.attributedText = textLabel.text?.styled(with: configuration.textStringStyle)
    primaryButton.configuration = configuration.primaryButtonConfiguration
    secondaryButton.configuration = configuration.secondaryButtonConfiguration
    primaryButtonHeightConstraint?.constant = configuration.buttonHeight
  }

}
