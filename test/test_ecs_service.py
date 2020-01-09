import json
import unittest

from subprocess import check_call, check_output

class TestCreateService(unittest.TestCase):

    def setUp(self):
        check_call(['terraform', 'get', 'test/infra'])
        check_call(['terraform', 'init', 'test/infra'])

    def get_output_json(self):
        return json.loads(check_output([
            'terraform',
            'show',
            '-json',
            'plan.out'
        ]).decode('utf-8'))

    def get_resource_changes(self):
        output = self.get_output_json()
        return output.get('resource_changes')

    def assert_resource_changes_action(self, resource_changes, action, length):
        resource_changes_create = [
            rc for rc in resource_changes
            if rc.get('change').get('actions') == [action]
        ]
        assert len(resource_changes_create) == length

    def assert_resource_changes(self, testname, resource_changes):
        with open(f'test/files/{testname}.json', 'r') as f:
            data = json.load(f)

            assert data.get('resource_changes') == resource_changes

    def test_create_ecs_service(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.service',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 12
        self.assert_resource_changes_action(resource_changes, 'create', 10)
        self.assert_resource_changes('create_ecs_service', resource_changes)

    def test_create_ecs_service_with_name_suffix(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.service_with_name_suffix',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 12
        self.assert_resource_changes_action(resource_changes, 'create', 10)
        self.assert_resource_changes('create_ecs_service_with_name_suffix', resource_changes)

    def test_create_ecs_service_with_task_role_policy(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.service_with_task_role_policy',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 12
        self.assert_resource_changes_action(resource_changes, 'create', 10)
        self.assert_resource_changes('create_ecs_service_with_task_role_policy', resource_changes)
