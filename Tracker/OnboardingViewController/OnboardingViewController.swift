

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    var onboardingCompleted: (() -> Void)?
    
    private lazy var pages: [UIViewController] = {
        let blue = createPage(imageName: "onboardingBue", labelText: "Отслеживайте только \n то, что хотите")
        let red = createPage(imageName: "onboardingRed", labelText: "Даже если это \n не литры воды и йога")
        return [blue, red]
    }()
    
    private  lazy var pageControl: UIPageControl = {
        let pageControll = UIPageControl()
        pageControll.numberOfPages = pages.count
        pageControll.currentPage = 0
        
        pageControll.currentPageIndicatorTintColor = .black
        pageControll.pageIndicatorTintColor = .gray
        
        pageControll.translatesAutoresizingMaskIntoConstraints = false
        return pageControll
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        setupUI()
    }
    
    private func createPage(imageName: String, labelText: String) -> UIViewController {
        let page = UIViewController()
        
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: imageName)
        backgroundImage.contentMode = .scaleAspectFill
        page.view.addSubview(backgroundImage)
        page.view.sendSubviewToBack(backgroundImage)
        
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        page.view.addSubview(label)
        
        let button = UIButton()
        button.backgroundColor = .black
        button.tintColor = .white
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        page.view.addSubview(button)
        button.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: page.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: page.view.centerYAnchor,constant: 70),
        
            button.leadingAnchor.constraint(equalTo: page.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: page.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: page.view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            button.heightAnchor.constraint(equalToConstant: 60)

        ])
        
        return page
    }
    
    private func setupUI() {
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -140),
        ])
    }
    
    @objc
    private func didTapStartButton() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        onboardingCompleted?()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previosIndex = viewControllerIndex - 1
        guard previosIndex >= 0 else {
            return pages.last
        }
        guard pages.count > previosIndex else {
            return nil
        }
        return pages[previosIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
