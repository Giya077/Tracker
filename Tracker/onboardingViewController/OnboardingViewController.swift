

import UIKit

class OnboardingViewController: UIPageViewController {
    
    var onboardingCompleted: (() -> Void)?
    
    private let buttom: UIButton = {
        let buttom = UIButton()
        buttom.backgroundColor = .black
        buttom.tintColor = .white
        buttom.setTitle("Вот это технологии!", for: .normal)
        buttom.titleLabel?.textColor = .white
        buttom.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        buttom.layer.cornerRadius = 16
        buttom.layer.masksToBounds = true
        buttom.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        buttom.translatesAutoresizingMaskIntoConstraints = false
        return buttom
    }()
    
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
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: page.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: page.view.centerYAnchor,constant: 70)
        ])
        
        return page
    }
    
    private func setupUI() {
        
        view.addSubview(pageControl)
        view.addSubview(buttom)
        
        NSLayoutConstraint.activate([
            
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: buttom.topAnchor, constant: -20),
            
            buttom.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttom.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttom.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            buttom.heightAnchor.constraint(equalToConstant: 60)
            
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
