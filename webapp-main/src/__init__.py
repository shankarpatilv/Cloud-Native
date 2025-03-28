from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from .config import Config
from sqlalchemy_utils import database_exists,create_database

from .utilities import handle_response 


db = SQLAlchemy()


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)


    db.init_app(app)
    with app.app_context():
        url = db.engine.url 
        print(url)
        if not database_exists(url):
            create_database(url)
        from .models import user_model, images_model , user_verify
        db.create_all() 
    
    @app.route('/v1/user/self', methods=['HEAD', 'OPTIONS'])
    @app.route('/healthz', methods=['HEAD', 'OPTIONS'])
    @app.route('/v1/user', methods=['HEAD', 'OPTIONS'])
    def check():
        return handle_response(405)


    from .routes.health_routes import health_bp
    from .routes.user_routes import user_bp
    from .routes.verify import verification_bp
    from .routes.cicd_test import cicd_bp
    app.register_blueprint(health_bp)
    app.register_blueprint(user_bp)
    app.register_blueprint(verification_bp)
    app.register_blueprint(cicd_bp)
    @app.errorhandler(405)
    def not_found(error):
        return handle_response(405)

    @app.errorhandler(404)
    def not_found(error):
        return handle_response(404)
    
    @app.errorhandler(400)
    def not_found(error):
        return handle_response(400)
    
    @app.errorhandler(401)
    def not_found(error):
        return handle_response(401)
    
    @app.errorhandler(500)
    def not_found(error):
        return handle_response(503)
    return app
